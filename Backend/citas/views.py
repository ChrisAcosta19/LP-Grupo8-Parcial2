from django.shortcuts import render
from django.http import JsonResponse
from .models import Cita

def citas_por_profesional(request, profesional_id):
    citas = Cita.objects.filter(profesional_id=profesional_id)
    data = list(citas.values('id', 'cliente__nombre', 'fecha_hora', 'estado'))
    return JsonResponse(data, safe=False)