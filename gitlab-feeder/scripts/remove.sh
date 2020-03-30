#! /bin/bash

mkdir -p ${GITLAB_FEEDER_BASEPATH}
cd ${GITLAB_FEEDER_BASEPATH}

echo 'grant_type=password&username=root&password=delivery' > auth.txt
token=$(curl --data "@auth.txt" --request POST http://gitlab.lan.com/oauth/token 2>/dev/null | jq '.access_token')
token="${token%\"}"
token="${token#\"}"
rm auth.txt

curl --header "Authorization: Bearer ${token}" -X GET http://gitlab.lan.com/api/v4/projects 2>/dev/null | jq '.[] | .id' | while read project_id; do
  curl --header "Authorization: Bearer ${token}" -X DELETE http://gitlab.lan.com/api/v4/projects/${project_id} 2>/dev/null
done

backends_group_id=$(curl --header "Authorization: Bearer ${token}" http://gitlab.lan.com/api/v4/groups 2>/dev/null | jq '.[0] | .id')
curl --header "Authorization: Bearer ${token}" -X DELETE http://gitlab.lan.com/api/v4/groups/${backends_group_id} 2>/dev/null
