#!/bin/sh
api_token=""
domain=""

# Enter the API Username, API Password and JSS URL here
apiuser="" 
apipass=""
jssURL=""


token_auth(){
# created base64-encoded credentials
encoded=$( printf "${apiuser}:${apipass}" | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i -)

curlCmd="/usr/bin/curl --silent --show-error"
url="${jssURL}/api/v1/auth/token"

authTokenJson=$(${curlCmd} \
  --header "Authorization: Basic $encoded" \
  --request "POST" \
  "${url}")

token=$(/usr/bin/plutil -extract "token" raw -expect "string" -o - - <<< "${authTokenJson}")
}

token_auth
#Get user info s
get_email_jamfpro(){


# Get the Mac's UUID string
UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')

email=$(curl -H "Accept: text/xml" -sk -H "authorization: Bearer $token" "${jssURL}/JSSResource/computers/udid/${UUID}/subset/location" | xmllint --format - 2>/dev/null | awk -F'>|<' '/<email_address>/{print $3}')
echo "$email"
}

get_okta_email_status_code(){
    curl -s -X GET \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: SSWS ${api_token}" "https://${domain}/api/v1/users/$user_email" \
-o /dev/null \
-w '%{http_code}\n'
}

get_okta_email(){
    curl -s -X GET \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: SSWS ${api_token}" "https://${domain}/api/v1/users/$user_email"
}

expire_token(){
    # expire the auth token
/usr/bin/curl "$jssURL/api/auth/invalidateToken" \
--silent \
--request POST \
--header "Authorization: Bearer $token"
echo "Token expired"
}

#email address from jamf
user_email_jamfpro=$(get_email_jamfpro)


jsonData=$(get_okta_email)

useremail_okta=$(echo $jsonData | sed -e 's/[{}]/''/g' | sed s/\"//g | awk -v RS=',' -F: '$1=="email"{print $2}')
echo $useremail_okta

#Let us expire the token
expire_token
exit 0



  
        
 
