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
from usuarios.views import crear_usuario, lista_usuarios, lista_cliente, lista_administradores, actualizar_usuario, eliminar_usuario, usuario_por_id
from profesionales.views import asignar_profesion, consultar_profesiones, lista_profesionales, obtener_id_profesional
from profesiones.views import lista_profesiones, crear_profesion, consultar_profesion
from citas.views import citas_por_cliente, citas_por_profesional, crear_cita_para_cliente, buscar_profesionales, obtener_profesionales_por_profesion, obtener_ubicaciones_y_horarios,crear_cita_admin,lista_citas_admin, buscar_horarios_por_profesional, update_cita, cancelar_cita
from ubicaciones.views import crear_ubicacion, eliminar_ubicacion, lista_ubicaciones, listar_ubicaciones_id_usuario, crear_ubicacion_sin_form, listar_ubicaciones_id_profesional
from citas.views import citas_por_cliente
from citas.views import crear_cita_para_cliente
from citas.views import buscar_profesionales
from citas.views import obtener_profesionales_por_profesion
from citas.views import obtener_ubicaciones_y_horarios
from citas.views import crear_cita_admin
from citas.views import lista_citas_admin
from usuarios.views import usuario_por_id
from ubicaciones.views import crear_ubicacion, eliminar_ubicacion, lista_ubicaciones, listar_ubicaciones_id_usuario, crear_ubicacion_sin_form
from citas.views import buscar_horarios_por_profesional
from citas.views import cancelar_cita_y_crear_horario

urlpatterns = [
    path('admin/', admin.site.urls),
    path('profesional/<int:usuario_id>/horarios/', horarios_por_profesional, name='horarios_por_profesional'),
    path('profesional/<int:profesional_id>/horarios/crear/', crear_horario_disponible, name='crear_horario_disponible'),
    path('profesional/<int:profesional_id>/ubicaciones/crear/', crear_ubicacion_sin_form, name='crear_ubicacion_sin_form'),
    path('profesional/<int:usuario_id>/ubicaciones/', listar_ubicaciones_id_usuario, name='listar_ubicaciones_id_usuario'),
    path('profesional/<int:profesional_id>/ubicacionesProfesional/', listar_ubicaciones_id_profesional, name='listar_ubicaciones_id_profesional'),
    path('profesional/<int:usuario_id>/citas/', citas_por_profesional, name='citas_por_profesional'),
    path('profesional/citas/<int:cita_id>/actualizar/', update_cita, name='update_cita'),
    path('profesional/citas/<int:cita_id>/cancelar/', cancelar_cita, name='cancelar_cita'),
    path('profesional/<int:usuario_id>/profesiones/', consultar_profesiones, name='consultar_profesiones'),
    path('profesional/<int:usuario_id>/profesion/<int:profesion_id>/', obtener_id_profesional, name='obtener_id_profesional'),
    path('profesion/<str:nombre_profesion>/', consultar_profesion, name='consultar_profesion'),
    path('cliente/<int:usuario_id>/citas/crear', crear_cita_para_cliente, name='crear_cita_para_cliente'),
    path('cliente/<int:usuario_id>/citas/', citas_por_cliente, name='citas_por_cliente'),
    path('usuarios/<int:usuario_id>/buscar/', usuario_por_id, name='usuario_por_id'),
    path('usuarios/<int:usuario_id>/', usuario_por_id, name='usuario_por_id'),
    path('usuarios/crear/', crear_usuario, name='crear_usuario'),
    path('usuarios/lista/', lista_usuarios, name='lista_usuarios'),
    path('usuarios/clientes/', lista_cliente, name='lista_cliente'),
    path('usuarios/profesionales/', lista_profesionales, name='lista_profesionales'),
    path('usuarios/administradores/', lista_administradores, name='lista_administradores'),
    path('usuarios/actualizar/<int:usuario_id>/', actualizar_usuario, name='actualizar_usuario'),
    path('usuarios/eliminar/<int:usuario_id>/', eliminar_usuario, name='eliminar_usuario'),
    path('profesiones/lista/', lista_profesiones, name='lista_profesiones'),
    path('profesiones/crear/', crear_profesion, name='crear_profesion'),
    path('profesionales/asignar-profesion/', asignar_profesion, name='asignar_profesion'),
    path('usuarios/clientes/buscar-profesionales/', buscar_profesionales, name='buscar_profesionales'),
    path('ubicaciones/crear/', crear_ubicacion, name='crear_ubicacion'),
    path('ubicaciones/eliminar/<int:ubicacion_id>/', eliminar_ubicacion, name='eliminar_ubicacion'),
    path('ubicaciones/lista', lista_ubicaciones, name='lista_ubicaciones'),  # Lista de ubicaciones
    path('profesionales/profesion/<int:profesion_id>/', obtener_profesionales_por_profesion, name='obtener_profesionales_por_profesion'),
    path('ubicaciones_horarios/<int:profesional_id>/', obtener_ubicaciones_y_horarios, name='obtener_ubicaciones_y_horarios'),
    path('administrador/crear_cita/', crear_cita_admin, name='crear_cita_admin'),
    path('administrador/lista_citas/', lista_citas_admin, name='lista_citas_admin'),

    path('usuarios/citas/horarios_disponibles', buscar_horarios_por_profesional, name='obtener_horarios_por_profesionales'),
    path('usuario/citas/<int:cita_id>/', cancelar_cita_y_crear_horario, name='cancelar_cita_y_crear_horario'),
]