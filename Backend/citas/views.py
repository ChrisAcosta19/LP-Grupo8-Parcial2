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

    #return render(request, 'horarios/crear_horario_disponible.html', {'form': form})
    return render(request, 'citas/crear_cita_clientes.html', {'form': form})