#! /bin/bash

mkdir -p ${GITLAB_FEEDER_BASEPATH}
cd ${GITLAB_FEEDER_BASEPATH}

dpkg -l | grep jq 2>&1 >/dev/null || {
  apt update
  apt install --yes jq
}

echo 'grant_type=password&username=root&password=delivery' > auth.txt
token=$(curl --data "@auth.txt" --request POST http://gitlab.lan.com/oauth/token 2>/dev/null | jq '.access_token')
token="${token%\"}"
token="${token#\"}"
rm auth.txt

group_id=$(curl --header "Authorization: Bearer ${token}" -X POST "http://gitlab.lan.com/api/v4/groups?name=backends&path=backends&description=Groups%20for%20backends" 2>/dev/null | jq '.id')

for backend in affiliation assureci authentification contentieux declaration-salaire facturation finance personne recherche sedex; do
  curl --header "Authorization: Bearer ${token}" -X POST "http://gitlab.lan.com/api/v4/projects?name=${backend}&path=${backend}&namespace_id=${group_id}&${description}=Service%20for%20${backend}"

  [ -d ${backend} ] && {
    rm -rf ${backend}
  }

  git clone http://root:delivery@gitlab.lan.com/backends/${backend}.git
  cd ${backend}

  touch README.md
  git add README.md
  git commit -m "add README"

  git push -u origin master

  for branch in develop CI/Set-basic-pipeline FEATURE/New-pom BUGFIX/Remove-unused-quotes FEATURE/Add-new-preview-module ; do
    git checkout -b ${branch}
    echo "current branch: ${branch}" > branch.txt

    git add branch.txt
    git commit --message "Add branch in descriptive file"
    git push -u origin ${branch}
  done

  git checkout develop
  git tag "0.25.10"

  git checkout CI/Set-basic-pipeline
  git tag "0.25.11"

  git checkout FEATURE/New-pom
  git tag "0.25.12"

  git push --tags

  cd ..
done
