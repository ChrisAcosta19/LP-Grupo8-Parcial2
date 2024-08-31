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
    # Obtener todos los profesionales y sus datos relacionados
    profesionales = Profesional.objects.select_related('usuario', 'profesion').all()

    # Convertir los datos a un formato que se pueda usar en JSON
    data = [
        {
            'id': profesional.usuario.id,
            'nombre': profesional.usuario.nombre,
            'correo_electronico': profesional.usuario.correo_electronico,
            'rol': profesional.usuario.rol,
            'profesion': profesional.profesion.nombre_profesion
        }
        for profesional in profesionales
    ]

    return JsonResponse(data, safe=False)


def consultar_profesiones(request, usuario_id):
    profesiones = Profesional.objects.filter(usuario_id=usuario_id)
    data = list(profesiones.values('id', 'usuario__nombre', 'profesion__nombre_profesion'))
    return JsonResponse(data, safe=False)