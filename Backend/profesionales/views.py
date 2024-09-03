from django.shortcuts import render, redirect
from django.http import JsonResponse
from .forms import ProfesionalForm
from .models import Profesional
from ubicaciones.models import Ubicacion


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

    # Crear una lista para almacenar los datos
    data = []

    for profesional in profesionales:
        # Obtener la dirección asociada al usuario
        ubicacion = Ubicacion.objects.filter(usuario=profesional.usuario).first()  # Suponemos que puede haber una sola dirección por usuario
        
        # Añadir la información a la lista de datos
        data.append({
            'id': profesional.usuario.id,
            'nombre': profesional.usuario.nombre,
            'correo_electronico': profesional.usuario.correo_electronico,
            'rol': profesional.usuario.rol,
            'profesion': profesional.profesion.nombre_profesion,
            'direccion': ubicacion.direccion if ubicacion else 'No disponible'  # Añadir la dirección
        })

    return JsonResponse(data, safe=False)


def consultar_profesiones(request, usuario_id):
    profesiones = Profesional.objects.filter(usuario_id=usuario_id)
    data = list(profesiones.values('id', 'usuario__nombre', 'profesion__nombre_profesion'))
    return JsonResponse(data, safe=False)


def obtener_id_profesional(request, usuario_id, profesion_id):
    profesional = Profesional.objects.get(usuario_id=usuario_id, profesion_id=profesion_id)
    data = {
        'id': profesional.id,
        'usuario_id': profesional.usuario_id,
        'usuario_nombre': profesional.usuario.nombre,
        'profesion_nombre': profesional.profesion.nombre_profesion
    }
    return JsonResponse(data, safe=False)
