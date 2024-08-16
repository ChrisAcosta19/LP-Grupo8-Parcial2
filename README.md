# LP-Grupo8-Parcial2
## Pasos para ejecutar el proyecto
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

5. Para usar el Panel de Administración de Django, primero crear un superusuario con el comando en la terminal desde el directorio Backend\Backend:
- python manage.py createsuperuser

6. En la terminal desde el directorio Backend\Backend ejecutar el siguiente comando para iniciar el servidor de desarrollo:
- python manage.py runserver

7. Para acceder a la interfaz del Panel de Administración de Djando dirigirse al siguiente URL con las credenciales creadas en el paso 5.
- http://127.0.0.1:8000/admin
