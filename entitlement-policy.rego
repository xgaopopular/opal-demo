package entitlement

import future.keywords.in

result_constant := "result"

# Helper function to extract deposit accounts from products
deposit_accounts[key] := account if {
	some key, value in input.product
	startswith(key, "DepositAccount#")

	# Map roles to standardized format
	role_map := {
		"Sole Owner": "sole_owner",
		"Trustee": "trustee",
	}

	# Ensure value exists in role_map before creating account
	role_map[value]
	account = {
		"id": key,
		"role": role_map[value],
	}
}

# Helper function to extract credit cards from products
credit_cards[key] := card if {
	some key, value in input.product
	startswith(key, "CreditCardAccount#")

	# Map roles to standardized values
	role_map := {
		"Primary": "primary_account_holder",
		"Authorize": "authorized_user",
	}

	# Ensure value exists in role_map before creating account
	role_map[value]
	card = {
		"id": key,
		"role": role_map[value],
	}
}

# Fix case sensitivity in client_type and standardize
user_type := "retail" if {
	lower(input.client_type) == "retail"
}

user_type := "commercial" if {
	lower(input.client_type) == "commercial"
}

# ATH Movil Access: All retail, deposit account holders
allow_ath_movil[result_constant] if {
	user_type == "retail"
	count(deposit_accounts) > 0
}

# Basic Credit Card Features: All credit card holders
allow_basic_credit_card_features[result_constant] if {
	count(credit_cards) > 0
}

# View and Redeem Reward Points: All credit card, primary account holders
allow_view_redeem_reward_points[result_constant] := rtn if {
	some card in credit_cards
	rtn := card.role == "primary_account_holder"
}

# Pay Card Balance: All credit card holders (primary or authorized)
allow_pay_card_balance[result_constant] if {
	allow_role := {"primary_account_holder", "authorized_user"}
	some card in credit_cards
	card.role in allow_role
}

# Withdraw Functionality: All deposit account, sole owners
allow_withdraw[result_constant] if {
	some account in deposit_accounts
	account.role == "sole_owner"
}

# View Account Balance: All deposit account holders (sole owners or trustees)
allow_view_account_balance[result_constant] if {
	some account in deposit_accounts
}

# Priority Call Routing: All wealth clients
allow_priority_call_routing[result_constant] if {
	lower(input.client_segment) == "wealth"
}

# Tax Services: All regular, premium, and wealth clients
allow_tax_services[result_constant] if {
	 input.client_segment in {"regular", "premium", "wealth"}
}
