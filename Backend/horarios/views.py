from django.shortcuts import render, redirect

# Create your views here.
from django.http import JsonResponse
from .models import HorarioDisponible
from .forms import HorarioDisponibleForm

def horarios_por_profesional(request, profesional_id):
    horarios = HorarioDisponible.objects.filter(profesional_id=profesional_id)
    data = list(horarios.values('id', 'fecha', 'hora_inicio', 'hora_fin'))
    return JsonResponse(data, safe=False)

def crear_horario_disponible(request, profesional_id):
    if request.method == 'POST':
        form = HorarioDisponibleForm(request.POST)
        if form.is_valid():
            horario = form.save(commit=False)
            horario.profesional_id = profesional_id
            horario.save()
            return redirect('horarios_por_profesional', profesional_id=profesional_id)
    else:
        form = HorarioDisponibleForm()
    return render(request, 'horarios/crear_horario_disponible.html', {'form': form})