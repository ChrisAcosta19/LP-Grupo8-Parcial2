from django.shortcuts import render
from django.http import JsonResponse
from .models import Cita

def citas_por_profesional(request, profesional_id):
    citas = Cita.objects.filter(profesional_id=profesional_id)
    data = list(citas.values('id','fecha','hora_inicio','hora_fin','ubicacion__direccion',
                             'cliente__nombre','profesional__usuario__nombre',
                             'profesional__profesion__nombre_profesion','estado'))
    return JsonResponse(data, safe=False)