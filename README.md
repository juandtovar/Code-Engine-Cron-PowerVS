# Code-Engine-Cron-PowerVS
_Este repositorio contiene los archivos necesarios para generar una aplicación en Code Engine en IBM Cloud que modifique los parámetros de un VSI de Power previamente creado usando suscripciones por eventos de Cron_

## Prerrequisitos
 - Tener una cuenta en [IBM Cloud](https://cloud.ibm.com/) con un grupo de recursos disponible (puede ser el _Default_).
 - Una api key para la cuenta de IBM Cloud.
 - Un espacio de trabajo de Power en IBM Cloud con un VSI.
 - Tener una cuenta de [Docker Hub](https://hub.docker.com/) o cualquier servicio en línea que proporcione un registro de contenedores para la plataforma Docker.
 - Tener una cuenta de [Github](https://github.com).

## Procedimiento

<!-- FALTA EL PEDAZO DE CREACIÓN DE LA LLAVE DE ACCESO SSH PARA GITHUB-->

<!-- FALTA EL PEDAZO DE CREACIÓN DE LA LLAVE DE ACCESO PARA DOCKERHUB-->

### Crear repositorio en Github
Puede clonar este repositorio o descargar su contenido y crear uno desde cero. Cuando ya esté creado ingrese al archivo _app_ y modifique los siguientes parámetros:
 - En la línea ```ibmcloud login --apikey APIKEY -r REGION``` reemplace el valor de ```APIKEY``` y ```REGION``` por su api key de su cuenta de IBM Cloud y la región correspondiente.
 - En la línea ```id_workspace=ID_WORKSPACE_POWER``` reemplace el valor de ```ID_WORKSPACE_POWER``` por el ID de su espacio de trabajo de Power en IBM Cloud.
 - En la línea ```id_vsi=ID_VSI_POWER``` reemplace el valor de ```ID_VSI_POWER``` por el ID de su VSI en el espacio de trabajo de Power.
 - En la línea ```CRN=CRN_WORKSPACE_POWER``` reemplace el valor de ```CRN_WORKSPACE_POWER``` por el CRN del espacio de trabajo de Power en IBM Cloud.
 - En las líneas de los comandos ```if``` y ```elif``` verifique las horas a las que desea realizar las modificaciones dentro del condicional ```[ "$hora_actual" -eq h ]```, reemplace el valor de ```h``` por la hora deseada (de 0 a 23), puede agregar más de estos casos si así lo desea.
 - En las líneas de los comandos ```curl``` verifique al final que se modifica el parámetro deseado con el valor deseado, por ejemplo ```'{"memory": 2}'``` para modificar la memoria RAM a 2 GB.

### Crear aplicación en Code Engine
En IBM Cloud entre al apartado **Catalog** > **Containers** > **Code Engine** > **Projects** > **Create**.

<!-- INSERTAR GIF DE IBM CLOUD -->

Complete los valores de las variables:
 - **Location**: Seleccione una de las localizaciones para desplegar sus aplicaciones de Code Engine, no necesariamente debe ser donde esté la instancia de Power.
 - **Name**: Un nombre para su proyecto de Code Engine.
 - **Resource group**: El grupo de recursos de su cuenta de IBM Cloud donde creará su proyecto de Code Engine.

De en **Create** y espere a que se cree su proyecto, una vez finalizada la creación de click sobre su proyecto y diríjase a la sección **Applications** > **Create**, allí llene los siguientes campos:
 - **General**
   - **Name**: Un nombre para su aplicación de Code Engine.
 - **Code**: Seleccione la opción **Source code**
   - **Code repo URL**: El link ssh de su repositorio en Github, para generarlo vaya a su repositorio en Github y entre al apartado **Code** > **Local** > **SSH**.
   - **Specify build details**
     - **Source**
       - **Code repo URL**: Debe aperecer el que ya se colocó anteriormente.
       - **Code repo access**: Aquí usaremos la llave ssh privada creada anteriormente para el repositorio, de click en las opciones y seleccione **Create code repo access**.
         - **Secret name**: Un nombre para el secreto de la llave ssh privada.
         - **SSH private key**: El valor de la llave ssh privada, puede cargar su valor desde el archivo que tenga en su máquina.
     - **Strategy**
       - **Dockerfile**: Debe contener el valor "Dockerfile".
       - **Timeout**: Dejarlo por default (10m).
       - **Build resources**: Seleccionar "S (0.5vCPU / 2 GB)".
     - **Output**: En este apartado puede configurar su servicio en línea que proporcione un registro de contenedores para la plataforma Docker, se presenta cómo hacerlo para Dockerhub.
       - **Registry name** > **Add**
         - **Secret name**: Un nombre para el secreto de su llave de acceso a Dockerhub.
         - **Secret contents** > **Target registry**: Seleccione la opción Dockerhub.
         - **Username**: Su usuario de dockerhub.
         - **Access token**: EL _access token_ creado anteriormente.
       - Deben aparecer actualizados los siguientes apartados:
         - **Registry server**: Debe contener el valor "https://index.docker.io/v1/".
         - **Registry secret**: El nombre que se le colocó al secreto.
         - **Namespace**: Su usuario de Dockerhub.
         - **Repository (image name)**: Puede ingresar un nombre para su repositorio en Dockerhub, preferiblemente uno con el cual identificar la imagen que se va a crear.
         - Dé click en **Done**.
 - **Resources & scaling**: Se recomienda dejar los valores por defecto a excepción de **CPU and memory** el cual se recomienda seleccionar el mínimo para esta aplicación (se puede moficiar más adelante).
 - **Domain mappings**: Seleccionar public.
 - **Optional settings**: Dejar valores por defecto.
 - Dé click en **Create**

Se empezará a construir la imagen, se demora aproximadamente minutos 4 minutos y luego se desplegará la aplicación, se demora aproximadamente minutos 2 minutos. Una vez desplegada nuestra aplicación puede correrla manualmente yendo al apartado **Application** y dar en **Open URL** de nuestra aplicación, verá que se abré una nueva pestaña (toma unos segundos en cargar) y verá una serie de mensaje de consola y un mensaje al final "No es hora", "Actualizado a 2" o Actualizado a 4" dependiendo de si es la hora que se programó el escalamiento.

### Crear suscripción por eventos de Cron
Dentro de su proyecto de Code engine diríjase a la sección **Event subscriptions** > **Create**, aquí se programará la ejecución de la aplicación por horas.
 - **General**
   - **Event type**: Seleccione _Periodic timer_
   - **Event subscription name**: Un nombre para el temporizador.
   - Dé click en **Next**.
 - **Schedule**
   - **Cron expression**: Aquí se configura cada cuánto quierer correr la aplicación, para este caso se debe programar todos los días cada **16** horas a partir de las 2 AM hora Bogotá (GMT -5) o **7** AM hora Greenwich (GMT 0), esto se logra colocando el valor "0 7/16 * * *" que ejecutará la aplicación todos los días a las 2AM y 6 PM hora Bogotá. https://crontab.cronhub.io/
