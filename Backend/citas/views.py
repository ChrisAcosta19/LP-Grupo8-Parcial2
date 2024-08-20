from django.shortcuts import render, redirect
from django.http import JsonResponse
from .models import Cita

def citas_por_profesional(request, profesional_id):
    citas = Cita.objects.filter(profesional_id=profesional_id)
    data = list(citas.values('id','fecha','hora_inicio','hora_fin','ubicacion__direccion',
                             'cliente__nombre','profesional__usuario__nombre',
                             'profesional__profesion__nombre_profesion','estado'))
    return JsonResponse(data, safe=False)

def citas_por_cliente(request, usuario_id):
    citas = Cita.objects.filter(cliente_id=usuario_id)
    data = list(citas.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'ubicacion__direccion',
                             'cliente__nombre', 'profesional__usuario__nombre',
                             'profesional__profesion__nombre_profesion', 'estado'))
    return JsonResponse(data, safe=False)


# Create your views here.
from .models import Cita
from .forms import CrearCitaParaCLienteForm

def crear_cita_para_cliente(request, usuario_id):
    if request.method == 'POST':
        form = CrearCitaParaCLienteForm(request.POST)
        if form.is_valid():
            cita = form.save(commit=False)
            cita.usuario_id = usuario_id
            cita.save()
            return redirect('citas_por_cliente', usuario_id=usuario_id)
    else:
        form = CrearCitaParaCLienteForm()

    return render(request, 'citas/crear_cita_clientes.html', {'form': form})

# BUSQUEDA PROFESIONAL
from .models import Profesional
from .forms import BuscarProfesionalForm

def buscar_profesionales(request):
    form = BuscarProfesionalForm(request.GET or None)
    profesionales = Profesional.objects.all()

    if form.is_valid():
        profesion = form.cleaned_data.get('profesion')
        disponible = form.cleaned_data.get('disponible')

        if profesion:
            profesionales = profesionales.filter(profesion=profesion)
        
        #if disponible is not None:
        #    profesionales = profesionales.filter(disponible=disponible)

    return render(request, 'citas/buscar_profesionales.html', {
        'form': form,
        'profesionales': profesionales
    })