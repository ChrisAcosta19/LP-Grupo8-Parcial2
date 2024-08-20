from django.http import JsonResponse
from .models import Profesion

def lista_profesiones(request):
    # Obtén todas las profesiones de la base de datos
    profesiones = Profesion.objects.all()
    # Convierte los datos a un formato que se pueda usar en JSON
    data = list(profesiones.values('id', 'nombre_profesion'))  # Ajusta según los campos de tu modelo
    return JsonResponse(data, safe=False)
