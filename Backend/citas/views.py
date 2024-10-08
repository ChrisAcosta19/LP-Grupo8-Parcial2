from django.shortcuts import render, redirect
from django.http import JsonResponse, Http404
from .models import Cita, Profesional
from ubicaciones.models import Ubicacion
from horarios.models import HorarioDisponible
from .forms import BuscarProfesionalForm
from .forms import BuscarHorariosPorProfesional
from .forms import CrearCitaParaCLienteForm
from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import get_object_or_404
import json

@csrf_exempt
def update_cita(request, cita_id):
    if request.method == 'PATCH':
        try:
            cita = get_object_or_404(Cita, id=cita_id)
            data = json.loads(request.body)

            # Actualizar solo los campos que están presentes en la solicitud
            if 'fecha' in data:
                cita.fecha = data['fecha']
            if 'hora_inicio' in data:
                cita.hora_inicio = data['hora_inicio']
            if 'hora_fin' in data:
                cita.hora_fin = data['hora_fin']
            if 'ubicacion' in data:
                ubicacion = get_object_or_404(Ubicacion, id=data['ubicacion'])
                cita.ubicacion = ubicacion

            cita.save()
            return JsonResponse({
                'id': cita.id,
                'fecha': cita.fecha,
                'hora_inicio': cita.hora_inicio,
                'hora_fin': cita.hora_fin,
                'ubicacion': cita.ubicacion.id,
            }, status=200)

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    else:
        return JsonResponse({'error': 'Método no permitido'}, status=405)
    
@csrf_exempt
def cancelar_cita(request, cita_id):
    if request.method == 'PATCH':
        try:
            cita = get_object_or_404(Cita, id=cita_id)
            cita.estado = 'Cancelada'
            cita.save()
            return JsonResponse({'message': 'Cita cancelada con éxito.'}, status=200)
        except json.JSONDecodeError:
            return JsonResponse({'error': 'Invalid JSON'}, status=400)
    else:
        return JsonResponse({'error': 'Método no permitido'}, status=405)

def citas_por_profesional(request, usuario_id):
    # Obtener todas las citas relacionadas con el profesional
    citas = Cita.objects.filter(profesional__usuario_id=usuario_id)
    
    if not citas:
        raise Http404("No hay citas para este profesional.")

    # Convertir los datos a una lista de diccionarios
    data = list(citas.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'ubicacion__direccion',
                             'cliente__nombre', 'profesional__usuario__nombre', 'profesional_id',
                             'profesional__profesion__nombre_profesion', 'estado'))
    
    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)


def citas_por_cliente(request, usuario_id):
    citas = Cita.objects.filter(cliente_id=usuario_id)
    data = list(citas.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'ubicacion__direccion',
                             'cliente__nombre', 'profesional__usuario__nombre',
                             'profesional__profesion__nombre_profesion', 'estado'))
    return JsonResponse(data, safe=False)


# ### CREA CITA PARA CLIENTES #### #
@csrf_exempt
def crear_cita_para_cliente(request, usuario_id):
    if request.method == 'POST':
        print(request.POST)  #haber que llega :c (NO OLVIDAR ELIMINAR Peter)

        form = CrearCitaParaCLienteForm(request.POST)
        if form.is_valid():
            print("entró")
            cita = form.save(commit=False)
            cita.usuario_id = usuario_id
            cita.cliente_id = request.POST.get('cliente')  # Esto asigna cliente dinámico

            # Filtro horarios disponibles por profesional
            horarios_disponibles = HorarioDisponible.objects.filter(
                profesional=cita.profesional,
                fecha=cita.fecha,
                hora_inicio=cita.hora_inicio
            )
            print(cita.profesional),
            print(cita.fecha),
            print(cita.hora_inicio),
            print(horarios_disponibles) #Estará filtrando?
            
            # Si se crea cita, eliminarlo horario
            if horarios_disponibles.exists():
                horarios_disponibles.delete()
            else:
                print("XD NO SE ELIMINÓ")

            cita.save()
            return redirect('citas_por_cliente', usuario_id=usuario_id)
        print("Form no Válido")

    else:
        form = CrearCitaParaCLienteForm()

    return render(request, 'citas/crear_cita_clientes.html', {'form': form})


# BUSQUEDA PROFESIONAL
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

    return render(request, 'citas/buscar_horarios.html', {
        'form': form,
        'profesionales': profesionales
    })

def obtener_profesionales_por_profesion(request, profesion_id):
    profesionales = Profesional.objects.filter(profesion_id=profesion_id).select_related('usuario')
    data = list(profesionales.values('id', 'usuario__nombre'))
    return JsonResponse(data, safe=False)

# BUSQUEDA HORARIOS PARA CITAS
def horarios_por_profesional(request, profesional_id):
    horarios = HorarioDisponible.objects.filter(profesional_id=profesional_id)
    data = list(horarios.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'profesional__profesion__nombre_profesion'))
    return JsonResponse(data, safe=False)


def buscar_horarios_por_profesional(request):
    form = BuscarHorariosPorProfesional(request.GET or None)
    profesionales = Profesional.objects.all()

    if form.is_valid():
        profesion = form.cleaned_data.get('profesion')
        profesional = form.cleaned_data.get('profesional')

        if profesion:
            profesionales = profesionales.filter(profesion=profesion)
        
        if profesional:
            profesionales = profesionales.filter(id=profesional.id)

    horarios = HorarioDisponible.objects.filter(profesional__in=profesionales)
    
    data = list(horarios.values('id', 'fecha', 'hora_inicio', 'hora_fin', 'profesional__profesion__nombre_profesion'))

    return JsonResponse(data, safe=False)
    """
    return render(request, 'citas/buscar_horarios.html', {
        'form': form,
        'profesionales': profesionales,
        'horarios': horarios,
    })
    """
    

def obtener_ubicaciones_y_horarios(request, profesional_id):
    ubicaciones = Ubicacion.objects.filter(profesional_id=profesional_id)
    horarios = HorarioDisponible.objects.filter(profesional_id=profesional_id)

    data = {
        'ubicaciones': list(ubicaciones.values('id', 'direccion')),
        'horarios': list(horarios.values('id', 'hora_inicio', 'hora_fin', 'fecha'))
    }
    return JsonResponse(data)


def crear_cita_admin(request):
    if request.method == 'POST':
        cliente_id = request.POST.get('cliente_id')
        profesional_id = request.POST.get('profesional_id')
        ubicacion_id = request.POST.get('ubicacion_id')
        fecha = request.POST.get('fecha')
        hora_inicio = request.POST.get('hora_inicio')
        hora_fin = request.POST.get('hora_fin')

        # Verificar si ya existe una cita para el mismo profesional, fecha, hora de inicio y hora de fin
        existe_cita = Cita.objects.filter(
            profesional_id=profesional_id,
            fecha=fecha,
            hora_inicio=hora_inicio,
            hora_fin=hora_fin
        ).exists()

        if existe_cita:
            return JsonResponse({'error': 'Ya existe una reservación para ese horario.'}, status=400)

        # Crear la cita si no existe
        cita = Cita.objects.create(
            cliente_id=cliente_id,
            profesional_id=profesional_id,
            ubicacion_id=ubicacion_id,
            fecha=fecha,
            hora_inicio=hora_inicio,
            hora_fin=hora_fin,
            estado='Agendada'  # Ajusta el estado según sea necesario
        )

        return JsonResponse({'message': 'Cita creada con éxito.', 'cita_id': cita.id})
    
    return JsonResponse({'error': 'Método no permitido'}, status=405)


def lista_citas_admin(request):
    # Obtener todas las citas de la base de datos con sus relaciones
    citas = Cita.objects.select_related('cliente', 'profesional', 'ubicacion').all()

    # Convertir los datos a una lista de diccionarios
    data = []
    for cita in citas:
        data.append({
            'id': cita.id,
            'cliente': {
                'id': cita.cliente.id,
                'nombre': cita.cliente.nombre,  # Asegúrate de que el modelo `Cliente` tiene un campo `nombre`
            },
            'profesional': {
                'id': cita.profesional.id,
                'nombre': cita.profesional.usuario.nombre,  # Asegúrate de que el modelo `Profesional` tiene una relación con el modelo `Usuario`
            },
            'ubicacion': {
                'id': cita.ubicacion.id,
                'direccion': cita.ubicacion.direccion,  # Asegúrate de que el modelo `Ubicacion` tiene un campo `direccion`
            },
            'fecha': cita.fecha,
            'hora_inicio': cita.hora_inicio,
            'hora_fin': cita.hora_fin,
            'estado': cita.estado,
        })

    # Devolver los datos como una respuesta JSON
    return JsonResponse(data, safe=False)

### ELIMINAR CITAS ###
from django.shortcuts import get_object_or_404, redirect

@csrf_exempt
def cancelar_cita_y_crear_horario(request, cita_id):
    try:
        # Obtener la cita a cancelar
        cita = get_object_or_404(Cita, id=cita_id)

        # Eliminar la cita
        cita.delete()

        # Crear un nuevo horario disponible
        HorarioDisponible.objects.create(
            profesional=cita.profesional,
            fecha=cita.fecha,
            hora_inicio=cita.hora_inicio,
            hora_fin=cita.hora_fin
        )

        return JsonResponse({'message': 'Cita cancelada y horario disponible creado exitosamente.'})

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)  


### REAGENDAR CITAS ###  
def reagendar_cita(request, cita_id):
    try:
        # Obtener la cita a cancelar
        cita = get_object_or_404(Cita, id=cita_id)

        # Obtener nueva fecha y hora del request
        nueva_fecha = request.POST.get('nueva_fecha')
        nueva_hora_inicio = request.POST.get('nueva_hora_inicio')
        nueva_hora_fin = request.POST.get('nueva_hora_fin')

        if nueva_fecha and nueva_hora_inicio and nueva_hora_fin:
            # Eliminar la cita
            cita.delete()

            # Crear una nueva cita con la nueva fecha y hora
            nueva_cita = Cita.objects.create(
                cliente=cita.cliente,
                profesional=cita.profesional,
                ubicacion=cita.ubicacion,
                fecha=nueva_fecha,
                hora_inicio=nueva_hora_inicio,
                hora_fin=nueva_hora_fin,
                estado='Reagendada'
            )

            return JsonResponse({'message': 'Cita reagendada con éxito.'})
        else:
            return JsonResponse({'error': 'Datos incompletos para reagendar la cita.'}, status=400)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)