#!/bin/bash

ibmcloud login --apikey APIKEY -r REGION

iam_token=$(ibmcloud iam oauth-tokens)

# Extraer el token de la salida
token=$(echo "$iam_token" | awk -F"Bearer " '{print $2}')

# Imprimir el token
# echo "IAM token: $token"

hora_actual=$(date +%H)

id_workspace=ID_WORKSPACE_POWER

id_vsi=ID_VSI_POWER

CRN=CRN_WORKSPACE_POWER

if [ "$hora_actual" -eq 18 ]; then
  curl -X PUT https://us-south.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/$id_workspace/pvm-instances/$id_vsi -H "Authorization: Bearer $token" -H "CRN: $CRN" -H 'Content-Type: application/json' -d '{"memory": 2}'
  echo -e "\nActualizado a 2" 
elif [ "$hora_actual" -eq 2 ]; then
  curl -X PUT https://us-south.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/$id_workspace/pvm-instances/$id_vsi -H "Authorization: Bearer $token" -H "CRN: $CRN" -H 'Content-Type: application/json' -d '{"memory": 4}'
  echo -e "\nActualizado a 4" 
else
  echo "No es hora"
fi
