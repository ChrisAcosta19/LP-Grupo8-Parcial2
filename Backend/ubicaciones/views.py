from django.shortcuts import render, redirect, get_object_or_404
from django.http import JsonResponse
from .models import Ubicacion
from .forms import UbicacionForm
from django.views.decorators.csrf import csrf_exempt
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
