from django.http import JsonResponse
from django.shortcuts import render, redirect
from .models import Profesion
from .forms import ProfesionForm


def lista_profesiones(request):
    # Obtén todas las profesiones de la base de datos
    profesiones = Profesion.objects.all()
    # Convierte los datos a un formato que se pueda usar en JSON
    data = list(profesiones.values('id', 'nombre_profesion'))  # Ajusta según los campos de tu modelo
    return JsonResponse(data, safe=False)


def crear_profesion(request):
    if request.method == 'POST':
        form = ProfesionForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('lista_profesiones')  # Redirige a la lista de profesiones
    else:
        form = ProfesionForm()

    return render(request, 'profesiones/crear_profesion.html', {'form': form})