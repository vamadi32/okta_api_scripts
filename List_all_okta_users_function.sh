#!/bin/sh
api_token="00mLEDAwt2HdInZVboJcPJOxFK3TdMMuz5hY_oFHLw"
domain="traderepublic.okta.com"

get_all_function(){
    curl -s -X GET \
-H "Accept: application/json" \
-H "Content-Type: application/json" \
-H "Authorization: SSWS ${api_token}" "https://${domain}/api/v1/users" sed -e 's/[{}]/''/g' | sed s/\"//g | awk -v RS=',' -F: '$1=="function"{print $2}' | sort | uniq
}

get_all_function