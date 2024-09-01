from django.http import JsonResponse
from .models import HorarioDisponible
from django.http import JsonResponse
from .models import HorarioDisponible
from django.views.decorators.csrf import csrf_exempt
import json

def horarios_por_profesional(request, profesional_id):
    horarios = HorarioDisponible.objects.filter(profesional__usuario_id=profesional_id)
    data = list(horarios.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'profesional__profesion__nombre_profesion'))
    return JsonResponse(data, safe=False)

@csrf_exempt
def crear_horario_disponible(request, profesional_id):
    if request.method == 'POST':
        body = json.loads(request.body)
        fecha = body['fecha']
        hora_inicio = body['horaInicio']
        hora_fin = body['horaFin']
        horario = HorarioDisponible(fecha=fecha, hora_inicio=hora_inicio, hora_fin=hora_fin, profesional_id=profesional_id)
        horario.save()
        return JsonResponse({'message': 'Horario disponible creado exitosamente'}, status=201)
    else:
        return JsonResponse({'error': 'Método no permitido'}, status=405)