from django.shortcuts import render, redirect
from django.http import JsonResponse
from .forms import ProfesionalForm
from .models import Profesional

def asignar_profesion(request):
    if request.method == 'POST':
        form = ProfesionalForm(request.POST)
        if form.is_valid():
            # Guarda el formulario y crea una instancia de Profesional
            profesional = form.save()
            
            # Opcional: Imprimir en consola (no visible en la consola del navegador)
            print(f"Profesional asignado: {profesional}")

            # Redirige a la lista de profesionales (debes tener definida esta vista y URL)
            return redirect('lista_profesionales')
    else:
        form = ProfesionalForm()
    
    # Renderiza el formulario en la plantilla
    return render(request, 'profesionales/asignar_profesion.html', {'form': form})

def lista_profesionales(request):
    profesionales = Profesional.objects.all()
    data = list(profesionales.values('id', 'usuario__nombre', 'profesion__nombre_profesion'))
    return JsonResponse(data, safe=False)
