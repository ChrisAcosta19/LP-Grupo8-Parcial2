import json
from django.shortcuts import get_object_or_404, render, redirect
from django.http import HttpResponse, JsonResponse
from .models import Usuario
from .forms import UsuarioProfesionalForm, UsuarioForm
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
from profesiones.models import Profesion
from profesionales.models import Profesional
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from ubicaciones.models import Ubicacion


def lista_usuarios(request):
    usuarios = Usuario.objects.all()
    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(usuarios.values('id', 'nombre', 'correo_electronico', 'rol'))
    return JsonResponse(data, safe=False)


def lista_cliente(request):
    # Filtrar usuarios con rol "Cliente"
    clientes = Usuario.objects.filter(rol='Cliente')

    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(clientes.values('id', 'nombre', 'correo_electronico', 'rol'))

    return JsonResponse(data, safe=False)


def lista_administradores(request):
    # Filtrar usuarios con rol "Cliente"
    clientes = Usuario.objects.filter(rol='Administrador')

    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(clientes.values('id', 'nombre', 'correo_electronico', 'rol'))

    return JsonResponse(data, safe=False)


def crear_usuario(request):
    if request.method == 'POST':
        rol = request.POST.get('rol')
        if rol == 'Profesional':
            form = UsuarioProfesionalForm(request.POST)
        else:
            form = UsuarioForm(request.POST)
        
        if form.is_valid():
            form.save()
            return redirect('lista_usuarios')  # Redirige a la lista de usuarios
    else:
        form = UsuarioForm()  # Por defecto, usa el formulario básico

    return render(request, 'usuarios/crear_usuario.html', {'form': form})


def usuario_por_id(request, usuario_id):
    usuario = Usuario.objects.get(id=usuario_id)
    data = {
        'id': usuario.id,
        'nombre': usuario.nombre,
        'correo_electronico': usuario.correo_electronico,
        'rol': usuario.rol
    }
    return JsonResponse(data, safe=False)


@csrf_exempt  # Solo para pruebas, no recomendado en producción
def actualizar_usuario(request, usuario_id):
    usuario = get_object_or_404(Usuario, id=usuario_id)
    
    if request.method == 'PUT':
        data = json.loads(request.body)
        usuario.nombre = data.get('nombre', usuario.nombre)
        usuario.correo_electronico = data.get('correo_electronico', usuario.correo_electronico)
        usuario.contrasena = data.get('contrasena', usuario.contrasena)
        usuario.rol = data.get('rol', usuario.rol)
        usuario.save()
        return JsonResponse({'status': 'Usuario actualizado correctamente'})
    return JsonResponse({'error': 'Method not allowed'}, status=405)




@csrf_exempt  # Solo para pruebas, no recomendado en producción
def eliminar_usuario(request, usuario_id):
    if request.method == 'DELETE':
        usuario = get_object_or_404(Usuario, id=usuario_id)
        usuario.delete()
        return JsonResponse({'status': 'Usuario eliminado correctamente'})
    return JsonResponse({'error': 'Method not allowed'}, status=405)


@csrf_exempt  # Solo para pruebas, no recomendado en producción
@require_http_methods(["POST"])
def crear_cliente(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        nombre = data.get('nombre')
        correo_electronico = data.get('correo_electronico')
        contrasena = data.get('contrasena')

        if not nombre or not correo_electronico or not contrasena:
            return JsonResponse({'error': 'Nombre, correo electrónico y contraseña son obligatorios'}, status=400)

        usuario = Usuario(nombre=nombre, correo_electronico=correo_electronico, contrasena=contrasena, rol='Cliente')
        usuario.save()
        return JsonResponse({'status': 'Usuario Cliente creado correctamente'}, status=201)

    return JsonResponse({'error': 'Method not allowed'}, status=405)


@csrf_exempt  # Solo para pruebas, no recomendado en producción
@require_http_methods(["POST"])
def crear_profesional(request):
    try:
        data = json.loads(request.body)
        nombre = data.get('nombre')
        correo_electronico = data.get('correo_electronico')
        contrasena = data.get('contrasena')

        if not nombre or not correo_electronico or not contrasena:
            return JsonResponse({'error': 'Nombre, correo electrónico y contraseña son obligatorios'}, status=400)

        usuario = Usuario(nombre=nombre, correo_electronico=correo_electronico, contrasena=contrasena, rol='Profesional')
        usuario.save()

        return JsonResponse({'status': 'Usuario creado correctamente', 'usuario_id': usuario.id}, status=201)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
@require_http_methods(["POST"])
def asignar_profesion(request):
    try:
        data = json.loads(request.body)
        usuario_id = data.get('usuario_id')
        profesion_id = data.get('profesion_id')

        if not usuario_id or not profesion_id:
            return JsonResponse({'error': 'usuario_id y profesion_id son obligatorios'}, status=400)

        try:
            usuario = Usuario.objects.get(id=usuario_id)
            profesion = Profesion.objects.get(id=profesion_id)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
        except Profesion.DoesNotExist:
            return JsonResponse({'error': 'Profesión no encontrada'}, status=404)

        usuario_profesion = Profesional(usuario=usuario, profesion=profesion)
        usuario_profesion.save()

        return JsonResponse({'status': 'Profesión asignada correctamente'}, status=201)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt
@require_http_methods(["PUT"])
def actualizar_profesion(request):
    try:
        data = json.loads(request.body)
        usuario_id = data.get('usuario_id')
        nueva_profesion_id = data.get('profesion_id')

        if not usuario_id or not nueva_profesion_id:
            return JsonResponse({'error': 'usuario_id y profesion_id son obligatorios'}, status=400)

        try:
            usuario = Usuario.objects.get(id=usuario_id)
            nueva_profesion = Profesion.objects.get(id=nueva_profesion_id)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
        except Profesion.DoesNotExist:
            return JsonResponse({'error': 'Profesión no encontrada'}, status=404)

        # Actualizar la profesión del usuario
        usuario_profesion = Profesional.objects.filter(usuario=usuario).first()
        
        if usuario_profesion:
            usuario_profesion.profesion = nueva_profesion
            usuario_profesion.save()
            return JsonResponse({'status': 'Profesión actualizada correctamente'}, status=200)
        else:
            return JsonResponse({'error': 'Profesión actual del usuario no encontrada'}, status=404)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


def obtener_id_usuario(request):
    nombre = request.GET.get('nombre')
    if nombre:
        try:
            usuario = Usuario.objects.get(nombre=nombre)
            return JsonResponse({'id': usuario.id})
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado'}, status=404)
    else:
        return JsonResponse({'error': 'Nombre no proporcionado'}, status=400)


@require_http_methods(["DELETE"])
def eliminar_profesion(request, id):
    try:
        profesion = Profesion.objects.get(profesional_id=id)
        profesion.delete()
        return HttpResponse(status=204)
    except Profesion.DoesNotExist:
        return HttpResponse(status=404)

@require_http_methods(["DELETE"])
def eliminar_ubicacion2(request, ubicacion_id):
    try:
        ubicacion = Ubicacion.objects.get(id=ubicacion_id)
        ubicacion.delete()
        return HttpResponse(status=204)
    except Ubicacion.DoesNotExist:
        return HttpResponse(status=404)

@require_http_methods(["DELETE"])
def eliminar_profesional(request, id):
    try:
        profesional = Profesional.objects.get(id=id)
        profesional.delete()
        return HttpResponse(status=204)
    except Profesional.DoesNotExist:
        return HttpResponse(status=404)
    try:
        profesional = Profesional.objects.get(id=id)
        # Asumimos que la relación se elimina aquí
        profesional.profesion.clear()  # O el método adecuado para eliminar la relación
        return Response(status=status.HTTP_204_NO_CONTENT)
    except Profesional.DoesNotExist:
        return Response(status=status.HTTP_404_NOT_FOUND)