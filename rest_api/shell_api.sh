#!/usr/bin/env bash

# FILE: shell_api.sh
# DATE: 9/5/2018

chef_dir() {
  if [ "$PWD" = "/" ]; then
    if [ -d ".chef" ]; then
      echo "/.chef"
    elif [ -d "$HOME/.chef" ]; then
      echo "$HOME/.chef"
    fi
    return
  fi

  if [ -d '.chef' ]; then
    echo "${PWD}/.chef"
  else
    (cd ..; chef_dir)
  fi
}

chomp () {
  awk '{printf "%s", $0}'
}

chef_api_request() {
  local method path body timestamp chef_server_url client_name hashed_body hashed_path
  local canonical_request headers auth_headers

  chef_server_url="https://ocean-u16/organizations/kato101"
  if echo $chef_server_url | grep -q "/organizations/"; then
    endpoint=/organizations/${chef_server_url#*/organizations/}${2%%\?*}
  else
    endpoint=${2%%\?*}
  fi
  echo $endpoint

  path=${chef_server_url}$2
  client_name="frank"
  method=$1
  body=$3

  hashed_path=$(echo -n "$endpoint" | openssl dgst -sha1 -binary | openssl enc -base64)
  hashed_body=$(echo -n "$body" | openssl dgst -sha1 -binary | openssl enc -base64)
  timestamp=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

  canonical_request="Method:$method\nHashed Path:$hashed_path\nX-Ops-Content-Hash:$hashed_body\nX-Ops-Timestamp:$timestamp\nX-Ops-UserId:$client_name"
  headers="-H X-Ops-Timestamp:$timestamp \
    -H X-Ops-Userid:$client_name \
    -H X-Chef-Version:0.10.4 \
    -H Accept:application/json \
    -H X-Ops-Content-Hash:$hashed_body \
    -H X-Ops-Sign:version=1.0"

  auth_headers=$(printf "$canonical_request" | openssl rsautl -sign -inkey \
    "$(chef_dir)/${client_name}.pem" | openssl enc -base64 | chomp |  awk '{ll=int(length/60);i=0; \
    while (i<=ll) {printf " -H X-Ops-Authorization-%s:%s", i+1, substr($0,i*60+1,60);i=i+1}}')

  case $method in
    GET)
      curl_command="curl -k -s $headers $auth_headers $path"
      $curl_command | jq
      ;;
    *)
      echo "Unknown Method. I only know: GET" >&2
      return 1
      ;;
    esac
  }

 chef_api_request "$@"
 echo ""
