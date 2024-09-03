from django.http import JsonResponse
from .models import Profesion
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json


def lista_profesiones(request):
    # Obtén todas las profesiones de la base de datos
    profesiones = Profesion.objects.all()
    # Convierte los datos a un formato que se pueda usar en JSON
    data = list(profesiones.values('id', 'nombre_profesion'))  # Ajusta según los campos de tu modelo
    return JsonResponse(data, safe=False)


@csrf_exempt
@require_http_methods(["POST"])
def crear_profesion(request):
    try:
        data = json.loads(request.body)
        # Crea una nueva instancia de Profesion sin usar el serializador
        profesion = Profesion.objects.create(**data)
        # Devuelve la nueva profesión en la respuesta
        response_data = {
            'id': profesion.id,
            'nombre_profesion': profesion.nombre_profesion,
        }
        return JsonResponse(response_data, status=201)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except TypeError:
        return JsonResponse({'error': 'Invalid data'}, status=400)


@csrf_exempt
@require_http_methods(["PUT"])
def actualizar_profesion_admin(request, id):
    try:
        data = json.loads(request.body)
        profesion = Profesion.objects.get(pk=id)
        # Actualiza los campos de la profesión sin usar el serializador
        for attr, value in data.items():
            setattr(profesion, attr, value)
        profesion.save()
        response_data = {
            'id': profesion.id,
            'nombre_profesion': profesion.nombre_profesion,
        }
        return JsonResponse(response_data)
    except Profesion.DoesNotExist:
        return JsonResponse({'error': 'Profesión no encontrada'}, status=404)
    except json.JSONDecodeError:
        return JsonResponse({'error': 'Invalid JSON'}, status=400)
    except TypeError:
        return JsonResponse({'error': 'Invalid data'}, status=400)


@csrf_exempt
@require_http_methods(["DELETE"])
def eliminar_profesion(request, id):
    try:
        profesion = Profesion.objects.get(pk=id)
        profesion.delete()
        return JsonResponse({'message': 'Profesión eliminada'}, status=200)
    except Profesion.DoesNotExist:
        return JsonResponse({'error': 'Profesión no encontrada'}, status=404)


def consultar_profesion(request, nombre_profesion):
    try:
        profesion = Profesion.objects.get(nombre_profesion=nombre_profesion)
        data = {
            'id': profesion.id,
            'nombre_profesion': profesion.nombre_profesion,
        }
        return JsonResponse(data)
    except Profesion.DoesNotExist:
        return JsonResponse({'error': 'Profesión no encontrada'}, status=404)
