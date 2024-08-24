# LP-Grupo8-Parcial2
## Pasos para ejecutar el Backend
1. Intalar Django con el comando (si ya está instalado omita este paso) :
- pip install django

2. En el archivo Backend\Backend\settings.py modificar los valores de las claves 'USER' y 'PASSWORD' del diccionario DATABASES con las credenciales respectivas del usuario root de MySQL.

3. Para crear la base de datos, en un script SQL ejecutar las siguientes sentencias en MySQL Workbench:
- DROP DATABASE IF EXISTS gestion_citas;
- CREATE DATABASE gestion_citas;
- USE gestion_citas;

4. Para crear las tablas en la base de datos, ejecutar los siguientes comandos en la terminal desde el directorio Backend\Backend:
- python manage.py makemigrations
- python manage.py migrate

5. Para poblar las tablas creadas en el paso 4, ejecutar el archivo Database\DML_gestion_citas.sql en MySQL Workbench.

6. Para usar el Panel de Administración de Django, primero crear un superusuario con el comando en la terminal desde el directorio Backend:
- python manage.py createsuperuser

7. En la terminal desde el directorio Backend ejecutar el siguiente comando para iniciar el servidor de desarrollo:
- python manage.py runserver

8. Para acceder a la interfaz del Panel de Administración de Djando dirigirse al siguiente URL con las credenciales creadas en el paso 5.
- http://127.0.0.1:8000/admin

## Pasos para ejecutar el Frontend
1. Intalar Flutter en VS Code:
- Windows: https://docs.flutter.dev/get-started/install/windows/web
- Linux: https://docs.flutter.dev/get-started/install/linux/web
- macOS: https://docs.flutter.dev/get-started/install/macos/web

2. Instalar la extensión de Flutter para VS Code (en caso de no haberlo hecho en el paso 1).

3. Abrir la terminal en Frontend\gestion_citas y ejecutar el comando:
- run_web.bat