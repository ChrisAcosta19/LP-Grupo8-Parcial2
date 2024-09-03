from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from usuarios.models import Usuario
from .models import Ubicacion
import json


@csrf_exempt  # Solo para pruebas, no recomendado en producción
@require_http_methods(["POST"])
def crear_ubicacion(request):
    try:
        data = json.loads(request.body)
        direccion = data.get('direccion')
        usuario_id = data.get('usuario_id')  # Cambiado a usuario_id

        if not direccion or not usuario_id:
            return JsonResponse({'error': 'Dirección y usuario_id son obligatorios'}, status=400)

        try:
            # Buscar el usuario por ID
            usuario = Usuario.objects.get(id=usuario_id)
        except Usuario.DoesNotExist:
            return JsonResponse({'error': 'Usuario no encontrado'}, status=404)

        # Crear la nueva ubicación
        ubicacion = Ubicacion(direccion=direccion, usuario=usuario)  # Cambiado a usuario
        ubicacion.save()

        response_data = {
            'id': ubicacion.id,
            'direccion': ubicacion.direccion,
            'usuario_id': ubicacion.usuario.id,  # Cambiado a usuario_id
            'usuario_nombre': ubicacion.usuario.nombre  # Cambiado a usuario_nombre
        }
        
        return JsonResponse({'status': 'Ubicación creada correctamente', 'data': response_data}, status=201)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@csrf_exempt  # Solo para pruebas, no recomendado en producción
@require_http_methods(["PUT"])
def actualizar_ubicacion(request):
    try:
        data = json.loads(request.body)
        ubicacion_id = data.get('ubicacion_id')
        nueva_direccion = data.get('direccion')

        if not ubicacion_id or not nueva_direccion:
            return JsonResponse({'error': 'Ubicacion ID y nueva dirección son obligatorios'}, status=400)

        try:
            # Buscar la ubicación por ID
            ubicacion = Ubicacion.objects.get(id=ubicacion_id)
        except Ubicacion.DoesNotExist:
            return JsonResponse({'error': 'Ubicación no encontrada'}, status=404)

        # Actualizar la dirección
        ubicacion.direccion = nueva_direccion
        ubicacion.save()

        response_data = {
            'id': ubicacion.id,
            'direccion': ubicacion.direccion,
            'usuario_id': ubicacion.usuario.id,
            'usuario_nombre': ubicacion.usuario.nombre
        }

        return JsonResponse({'status': 'Ubicación actualizada correctamente', 'data': response_data}, status=200)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)


@require_http_methods(["POST"])
def eliminar_ubicacion(request, ubicacion_id):
    ubicacion = get_object_or_404(Ubicacion, id=ubicacion_id)
    if request.method == 'POST':
        ubicacion.delete()
        return redirect('lista_ubicaciones')  # Redirige a la lista de ubicaciones

    # Si quieres mostrar un mensaje de confirmación antes de eliminar
    return render(request, 'ubicaciones/eliminar_ubicacion.html', {'ubicacion': ubicacion})


@require_http_methods(["GET"])
def lista_ubicaciones(request):
    # Obtener todas las ubicaciones de la base de datos
    ubicaciones = Ubicacion.objects.all().select_related('usuario')  # Cambiado a usuario
    
    # Convertir los datos a una lista de diccionarios
    data = list(ubicaciones.values('id', 'direccion', 'usuario__nombre'))  # Cambiado a usuario__nombre
    
    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)
