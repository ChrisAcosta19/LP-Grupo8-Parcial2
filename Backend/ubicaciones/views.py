from django.http import JsonResponse
from django.shortcuts import get_object_or_404, redirect, render
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from usuarios.models import Usuario
from .models import Ubicacion
from .forms import UbicacionForm
import json

@csrf_exempt
def crear_ubicacion_sin_form(request, profesional_id):
    if request.method == 'POST':
        body = json.loads(request.body)
        direccion = body['direccion']
        ubicacion = Ubicacion(direccion=direccion, profesional_id=profesional_id)
        ubicacion.save()
        return JsonResponse({'message': 'Ubicacion creada exitosamente'}, status=201)
    else:
        return JsonResponse({'error': 'Método no permitido'}, status=405)

def crear_ubicacion(request):
    if request.method == 'POST':
        form = UbicacionForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('lista_ubicaciones')  # Redirige a la lista de ubicaciones
    else:
        form = UbicacionForm()

    return render(request, 'ubicaciones/crear_ubicacion.html', {'form': form})

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
            'profesional_id': ubicacion.profesional_id,
        }

        return JsonResponse({'status': 'Ubicación actualizada correctamente', 'data': response_data}, status=200)

    except json.JSONDecodeError:
        return JsonResponse({'error': 'Formato JSON inválido'}, status=400)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

def eliminar_ubicacion(request, ubicacion_id):
    ubicacion = get_object_or_404(Ubicacion, id=ubicacion_id)
    if request.method == 'POST':
        ubicacion.delete()
        return redirect('lista_ubicaciones')  # Redirige a la lista de ubicaciones

    # Si quieres mostrar un mensaje de confirmación antes de eliminar
    return render(request, 'ubicaciones/eliminar_ubicacion.html', {'ubicacion': ubicacion})

def lista_ubicaciones(request):
    # Obtener todas las ubicaciones de la base de datos
    ubicaciones = Ubicacion.objects.all().select_related('profesional')
    
    # Convertir los datos a una lista de diccionarios
    data = list(ubicaciones.values('id', 'direccion', 'profesional__usuario__nombre'))
    
    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)

def listar_ubicaciones_id_usuario(request, usuario_id):
    # Obtener todas las ubicaciones de un profesional específico
    ubicaciones = Ubicacion.objects.filter(profesional__usuario_id=usuario_id)
    
    # Convertir los datos a una lista de diccionarios
    data = list(ubicaciones.values('id', 'direccion', 'profesional__profesion__nombre_profesion'))
    
    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)

def listar_ubicaciones_id_profesional(request, profesional_id):
    # Obtener todas las ubicaciones de un profesional específico
    ubicaciones = Ubicacion.objects.filter(profesional_id=profesional_id)
    
    # Convertir los datos a una lista de diccionarios
    data = list(ubicaciones.values('id', 'direccion', 'profesional__profesion__nombre_profesion'))
    
    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)
