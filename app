#!/bin/bash

# Fail is any command fails
set -e


# ibmcloud ce app list


ibmcloud login --apikey q7nQI-xUIML6alQ-spQVoAMB0e5KJz9kLRghBozrxB7U -r us-south

iam_token=$(ibmcloud iam oauth-tokens)

# Extraer el token de la salida
token=$(echo "$iam_token" | awk -F"Bearer " '{print $2}')

# Imprimir el token
echo "IAM token: $token"

hora_actual=$(date +%H)

id_workspace=88b056cc-c43d-43b5-8e76-a509fbd6aca2

id_vsi=89aa8b4a-f0f7-49f0-800b-54f09cabc75b

CRN=crn:v1:bluemix:public:power-iaas:dal10:a/736c7cd58317415b8d28a03e0e81eaf5:88b056cc-c43d-43b5-8e76-a509fbd6aca2::

# Verificar la región

if [ "$hora_actual" -eq 2 ]; then
  curl -X PUT https://us-south.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/$id_workspace/pvm-instances/$id_vsi -H "Authorization: Bearer $token" -H 'CRN: $CRN' -H 'Content-Type: application/json' -d '{"memory": 2}'
elif [ "$hora_actual" -eq 18 ]; then
  curl -X PUT https://us-south.power-iaas.cloud.ibm.com/pcloud/v1/cloud-instances/$id_workspace/pvm-instances/$id_vsi -H "Authorization: Bearer $token" -H 'CRN: $CRN' -H 'Content-Type: application/json' -d '{"memory": 4}'
else
  echo "No es hora"
fi
