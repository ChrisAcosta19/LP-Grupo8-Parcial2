"""
URL configuration for Backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from horarios.views import horarios_por_profesional, crear_horario_disponible
from citas.views import citas_por_profesional
from usuarios.views import crear_usuario, lista_usuarios, lista_cliente, lista_administradores
from profesionales.views import asignar_profesion
from profesiones.views import lista_profesiones
from citas.views import citas_por_cliente
from citas.views import crear_cita_para_cliente
from citas.views import buscar_profesionales


urlpatterns = [
    path('admin/', admin.site.urls),
    path('horarios/profesional/<int:profesional_id>/', horarios_por_profesional, name='horarios_por_profesional'),
    path('horarios/crear/<int:profesional_id>/', crear_horario_disponible, name='crear_horario_disponible'),
    path('citas/profesional/<int:profesional_id>/', citas_por_profesional, name='citas_por_profesional'),
    path('citas/crear/<int:usuario_id>/', crear_cita_para_cliente, name='crear_horario_disponible'),
    path('citas/cliente/<int:usuario_id>/', citas_por_cliente, name='citas_por_cliente'),
    path('usuarios/crear/', crear_usuario, name='crear_usuario'),
    path('usuarios/lista/', lista_usuarios, name='lista_usuarios'),
    path('usuarios/clientes/', lista_cliente, name='lista_cliente'),
    path('usuarios/administradores/', lista_administradores, name='lista_administradores'),
    path('profesiones/lista/',lista_profesiones, name='lista_profesiones'),
    path('profesionales/asignar-profesion/', asignar_profesion, name='asignar_profesion'),

    path('usuarios/clientes/buscar-profesionales/', buscar_profesionales, name='buscar_profesionales'),
]