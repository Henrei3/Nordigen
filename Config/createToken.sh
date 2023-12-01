#!/bin/bash

secret_id=$(awk -F\" '/"secret_id"/ {print $4}' ../key/Finances.json) 
secret_key=$(awk -F\" '/"secret_key"/ {print $4}' ../key/Finances.json) 

#Create an ACCESS_TOKEN
curl -X POST "https://ob.nordigen.com/api/v2/token/new/" \
  -H "accept: application/json" \
  -H  "Content-Type: application/json" \
  -d "{\"secret_id\":\"$secret_id\", \"secret_key\":\"$secret_key\"}" > ../key/ACCESS_KEY.txt

#On extrait la clé d'accès ainsi que l'identifiant de la banque a utiliser 

access_token=$(awk -F\" '/"access"/ {print $4}' ../key/ACCESS_KEY.txt)
institution_id=$(awk -F\" '{print $4}' ../Bank/SocieteGenerale.txt)

echo $access_token

#Build a Link
curl -X POST "https://ob.nordigen.com/api/v2/requisitions/" \
  -H  "accept: application/json" -H  "Content-Type: application/json" \
  -H  "Authorization: Bearer $access_token" \
  -d "{\"redirect\": \"https://docs.google.com/spreadsheets/d/1RyzR55wV20QPyA1mFheztwfyNofAFmNdYvZrhG18btU/edit#gid=0\",
       \"institution_id\": \"$institution_id\" }" > ../key/BankLink.txt

#On récupére le ID de notre link

link_id=$(awk -F\" '/"id"/ {print $4}' ../key/bankLink.txt) 

curl -X GET "https://ob.nordigen.com/api/v2/requisitions/$link_id/" \
  -H  "accept: application/json" \
  -H  "Authorization: Bearer $access_token" > tempLink.txt 

link=$(awk -F\" '/"link"/ {print $34}' tempLink.txt)

echo '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>URL</key>
	<string>'$link'</string>
</dict>
</plist>' > ../../../../Desktop/Authentificate.webloc

rm tempLink.txt
