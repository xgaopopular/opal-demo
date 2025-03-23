package lookup

import data.entitlement
import future.keywords.in

# Find user by CIS ID
find_user(cis, users) = user if {
    some i
    users[i].user_cis == cis
    user = users[i]
}

# Current user (based on input.user_cis)
current_user := user if {
    user := find_user(input.user_cis, data.users)
}
# Debug function to check user and products
debug_products_with_msg[msg] := user if {
    user := find_user(input.user_cis, data.users)
    msg := sprintf("Found user: %v with %d products", [user.user_cis, count(user.products)])
}
debug_info := info if {
    info := {
        "user_found": current_user != null,
        "user_cis": current_user.user_cis,
        "user_client_segment": current_user.client_segment,
        "client_lifestage": current_user.client_lifestage,
        "product_count": count(current_user.products),
        "sample_product": current_user.products[2]
    }
}
# For each product key in the user's product list, build a new input and check entitlements
entitlements_for_all_products[current_user.products[i]] := entitlements if {
    # Loop over each product entry in the user’s "products" array
    some i
    sprintf("product_id: %v", [current_user.products[i]])
    # Construct a new object that merges the current user data with the specific product ID.
    # (Here, we simply rebuild the fields we need from current_user along with "product".)
    user_with_this_product := {
        "user_cis": current_user.user_cis,
        "client_type": current_user.client_type,
        "client_segment": current_user.client_segment,
        "product": current_user.products[i]
    }
    sprintf("user_with_this_product: %v", [user_with_this_product])
     # Use 'with' statements correctly (outside the object construction)
    ath_result := entitlement.allow_ath_movil with input as user_with_this_product
    #For sets indexed by product_id, check if current product_id is in the set
    basic_cc_result := entitlement.allow_basic_credit_card_features with input as user_with_this_product
     view_rewards_result :=  entitlement.allow_view_redeem_reward_points with input as user_with_this_product
     pay_balance_result := entitlement.allow_pay_card_balance with input as user_with_this_product
     withdraw_result := entitlement.allow_withdraw with input as user_with_this_product
     view_balance_result := entitlement.allow_view_account_balance with input as user_with_this_product
     priority_call_result := entitlement.allow_priority_call_routing with input as user_with_this_product
     tax_services_result := entitlement.allow_tax_services with input as user_with_this_product


    # Construct the final entitlements object
    entitlements := {
        "allow_ath_movil":            ath_result,
         "basic_credit_card_features": basic_cc_result,
         "view_redeem_rewards":        view_rewards_result,
         "pay_balance":                pay_balance_result,
         "withdraw":                   withdraw_result, 
         "view_balance":               view_balance_result,
         "priority_call":              priority_call_result,
         "tax_services":               tax_services_result
    }
}
