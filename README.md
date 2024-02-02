# Code-Engine-Cron-PowerVS
_Este repositorio contiene los archivos necesarios para generar una aplicación en Code Engine en IBM Cloud que modifique los parámetros de un VSI de Power previamente creado usando suscripciones por eventos de Cron_







## Prerrequisitos
 - Tener una cuenta en [IBM Cloud](https://cloud.ibm.com/) con un grupo de recursos disponible (puede ser el _Default_).
 - Una api key para la cuenta de IBM Cloud.
 - Un espacio de trabajo de Power en IBM Cloud con un VSI.
 - Tener una cuenta de [Docker Hub](https://hub.docker.com/) o cualquier servicio en línea que proporcione un registro de contenedores para la plataforma Docker.
 - Tener una cuenta de [Github](https://github.com).








## Procedimiento

### Crear llave ssh para Github
En la terminal de nuestra máquina debemos ingresar el siguiente comando
```
ssh-keygen -t ed25519 -C "CORREO"
```
Reemplazando ```CORREO``` por nuestro correo de inicio de sesión de Github, nos pedirá ingresar un nombre para la llave ssh y luego una _passphrase_ es importante que dejemos este último espacio en blanco y solo dar enter, esto creara dos archivos con dos llaves, una privada y una pública en archivos del mismo nombre pero en el caso de la pública se obtiene la extensión .pub. Debemos copiar el archivo de la llave privada a la carpeta de archivos ssh de la máquina, esto se logra mediante
```
cp NOMBRE_LLAVE ~/.ssh
```
Reemplazando ```NOMBRE_LLAVE``` por el nombre que le hayamos colocado a la llave ssh. Ahora debemos agregar la llave a un _ssh-agent_ para ello debemos realizar los siguientes pasos:
1. Iniciar el _ssh-agent_, use el comando
```
eval "$(ssh-agent -s)"
```
Debe obtener un salida del tipo ```Agent pid #```.

2. Modificar el archivo de configuración de las llave ssh, acceda a él madiante el comando
```
open ~/.ssh/config
```
Si obtenemos un mensaje de que el archivo no existe debemos crearlo mediante
```
touch ~/.ssh/config
```
Y usar nuevamente el comando ```open```. Una vez dentro de este archivo debemos colocar lo siguiente
```
Host github.com
  IgnoreUnknown UseKeychain
  AddKeysToAgent yes
  IdentityFile ~/.ssh/NOMBRE_LLAVE
```
Reemplazar ```NOMBRE_LLAVE``` por el nombre que le hayamos colocado a la llave ssh y guardar.

3. Agregar la llave al _ssh-agent_, esto se logra madiante el comando
```
ssh-add --apple-use-keychain ~/.ssh/NOMBRE_LLAVE
```
Reemplazar ```NOMBRE_LLAVE``` por el nombre que le hayamos colocado a la llave ssh. Debemos obtener una salida del tipo ```Identity added: /Users/USUARIO/.ssh/NOMBRE_LLAVE (CORREO)```

4. Agregar la llave ssh a Github, diríjase a su cuenta de Github y dé click en su foto de perfil arriba a la derecha **Settings** > **SSH and GPG keys** > **New SSH key** y llene los valores de la siguiente manera:
 - **Title**: Un nombre para identificar la llave ssh en Github.
 - **Key type**: Selecciona Athentication Key.
 - **Key**: Copie y pegue la llave pública en este espacio, preferiblemente usar el comando
```
pbcopy < NOMBRE_LLAVE.pub
```
Reemplazar ```NOMBRE_LLAVE``` por el nombre que le hayamos colocado a la llave ssh. Repita este paso una vez más pero cambiando el **Key type** a Signing Key.







### Creación token de acceso de Dockerhub
Acceda a su cuenta de Dockerhub y dé click en su foto de perfil arriba a la derecha **My Account** > **Security** > **New Access Token** y llene los valores de la siguiente manera:
 - **Access Token Description**: Un nombre para identificar el token de acceso a crear.
 - **Access permissions**: Seleccione "Read, Write, Delete".
 - Dé click en **Generate**.
Tendrá un token de acceso a su cuenta de Dockerhub, guardar este valor para futuros accesos, tenga en cuenta que no podrá volver a acceder a este valor.







### Crear repositorio en Github
Descargue los archivos de este repositorio y cree uno nuevo CONFIGURELO DE MANERA PRIVADA YA QUE COLOCAREMOS INFORMACIÓN DE ACCESO A SU CUENTA DE IBM CLOUD. Cuando ya esté creado ingrese al archivo _app_ y modifique los siguientes parámetros:
 - En la línea ```ibmcloud login --apikey APIKEY -r REGION``` reemplace el valor de ```APIKEY``` y ```REGION``` por su api key de su cuenta de IBM Cloud y la región correspondiente.
 - En la línea ```id_workspace=ID_WORKSPACE_POWER``` reemplace el valor de ```ID_WORKSPACE_POWER``` por el ID de su espacio de trabajo de Power en IBM Cloud.
 - En la línea ```id_vsi=ID_VSI_POWER``` reemplace el valor de ```ID_VSI_POWER``` por el ID de su VSI en el espacio de trabajo de Power.
 - En la línea ```CRN=CRN_WORKSPACE_POWER``` reemplace el valor de ```CRN_WORKSPACE_POWER``` por el CRN del espacio de trabajo de Power en IBM Cloud.
 - En las líneas de los comandos ```if``` y ```elif``` verifique las horas a las que desea realizar las modificaciones dentro del condicional ```[ "$hora_actual" -eq h ]```, reemplace el valor de ```h``` por la hora deseada (de 0 a 23), puede agregar más de estos casos si así lo desea.
 - En las líneas de los comandos ```curl``` verifique que la región luego de "https://" corresponde con la de su instancias de power y verifique al final que se modifica el parámetro deseado con el valor deseado, por ejemplo ```'{"memory": 2}'``` para modificar la memoria RAM a 2 GB.







### Crear aplicación en Code Engine
En IBM Cloud entre al apartado **Catalog** > **Containers** > **Code Engine** > **Projects** > **Create**.

<img width="700" alt="workspace" src="images/code_engine.gif">

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
         - **SSH private key**: El valor de la llave ssh privada, puede cargar su valor desde el archivo que tenga en su máquina o copiarla usando el comando
         ```
         pbcopy < NOMBRE_LLAVE
         ```
         - Dé click en **Create**.
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
         - Dé click en **Create**.
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
   - **Cron expression**: Aquí se configura cada cuánto quierer correr la aplicación, para este caso se debe programar todos los días cada **16** horas a partir de las 2 AM hora Bogotá (GMT -5) o **7** AM hora Greenwich (GMT 0), esto se logra colocando el valor "0 7/16 * * *" que ejecutará la aplicación todos los días a las 2AM y 6 PM hora Bogotá. Puede encontrar en la referencias una página a un generador de expresiones en cron que da a detalle lo que se crea y demás información de este tipo de expresiones.
  






# Referencias
 - https://github.com/IBM/CodeEngine/tree/main/bash
 - https://cloud.ibm.com/apidocs/power-cloud#pcloud-pvminstances-put
 - https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
 - https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
 - https://crontab.cronhub.io/






Autores: IBM Cloud Tech Sales - Juan Diego Tovar Cárdenas.
