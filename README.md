# Code-Engine-Cron-PowerVS
_Este repositorio contiene los archivos necesarios para generar una aplicación en Code Engine en IBM Cloud que modifique los parámetros de un VSI de Power previamente creado usando suscripciones por eventos de Cron_

## Prerrequisitos
 - Tener una cuenta en [IBM Cloud](https://cloud.ibm.com/) con un grupo de recursos disponible (puede ser el _Default_).
 - Una api key para la cuenta de IBM Cloud.
 - Un espacio de trabajo de Power en IBM Cloud con un VSI.
 - Tener una cuenta de [Docker Hub](https://hub.docker.com/) o cualquier servicio en línea que proporcione un registro de contenedores para la plataforma Docker.
 - Tener una cuenta de [Github](https://github.com).

## Procedimiento
### Crear repositorio en Github
Puede clonar este repositorio o descargar su contenido y crear uno desde cero. Cuando ya esté creado ingrese al archivo _app_ y modifique los siguientes parámetros:
 - En la línea ```ibmcloud login --apikey APIKEY -r REGION``` reemplace el valor de ```APIKEY``` y ```REGION``` por su api key de su cuenta de IBM Cloud y la región correspondiente.
 - En la línea ```id_workspace=ID_WORKSPACE_POWER``` reemplace el valor de ```ID_WORKSPACE_POWER``` por el ID de su espacio de trabajo de Power en IBM Cloud.
 - En la línea ```id_vsi=ID_VSI_POWER``` reemplace el valor de ```ID_VSI_POWER``` por el ID de su VSI en el espacio de trabajo de Power.
 - En la línea ```CRN=CRN_WORKSPACE_POWER``` reemplace el valor de ```CRN_WORKSPACE_POWER``` por el CRN del espacio de trabajo de Power en IBM Cloud.
 - En las líneas de los comandos ```if``` y ```elif``` verifique las horas a las que desea realizar las modificaciones dentro del condicional ```[ "$hora_actual" -eq h ]```, reemplace el valor de ```h``` por la hora deseada (de 0 a 23), puede agregar más de estos casos si así lo desea.
 - En las líneas de los comandos ```curl``` verifique al final que se modifica el parámetro deseado con el valor deseado, por ejemplo ```'{"memory": 2}'``` para modificar la memoria RAM a 2 GB.

### Crear aplicación en Code Engine

### Crear suscripción por eventos de Cron
