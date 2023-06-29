#!/bin/bash

access_token=null
api="https://api.adguard.io"
auth_api="https://auth.adguard-vpn.com"
user_agent="AdGuardVpn/2.3.100 (Linux; U; Android 9; RMX3551 Build/PQ3A.190705.003)"
application_id="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"

function user_lookup() {
	# 1 - email: (string): <email>
	curl --request POST \
		--url "$auth_api/api/1.0/user_lookup" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--data "request_id=adguard-android&email=$1"
}

function register() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	curl --request POST \
		--url "$auth_api/api/2.0/registration" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--data "password=$2&product=VPN&clientId=adguard-vpn-android&marketingConsent=false&source=VPN_APPLICATION&applicationId=$application_id&email=$1"
}

function login() {
	# 1 - email: (string): <email>
	# 2 - password: (string): <password>
	response=$(curl --request POST \
		--url "$auth_api/oauth/token" \
		--user-agent "$user_agent" \
		--header "content-type: application/x-www-form-urlencoded" \
		--data "password=$2&grant_type=password_2fa&scope=trust&source=VPN_APPLICATION&client_id=adguard-vpn-android&username=$1")
	if [ -n $(jq -r ".access_token" <<< "$response") ]; then
		access_token=$(jq -r ".access_token" <<< "$response")
	fi
	echo $response
}

function get_account_settings() {
	curl --request GET \
		--url "$api/account/api/1.0/account/settings" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: Bearer $access_token"
}

function get_licenses() {
	curl --request GET \
		--url "$api/account/api/1.0/products/licenses/vpn.json" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: Bearer $access_token"
}

function get_exclusion_services() {
	curl --request GET \
		--url "$api/api/v1/exclusion_services" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}

function get_bonuses() {
	curl --request GET \
		--url "$api/account/api/1.0/vpn/bonuses" \
		--user-agent "$user_agent" \
		--header "content-type: application/json" \
		--header "authorization: Bearer $access_token"
}

function get_locations() {
	curl --request GET \
		--url "$api/api/v2/locations/ANDROID?app_id=$application_id&token=$access_token" \
		--user-agent "$user_agent" \
		--header "content-type: application/json"
}
