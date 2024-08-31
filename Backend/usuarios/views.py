from django.shortcuts import get_object_or_404, render, redirect
from django.http import JsonResponse
from .models import Usuario
from .forms import UsuarioProfesionalForm, UsuarioForm
from django.views.decorators.http import require_http_methods

def lista_usuarios(request):
    usuarios = Usuario.objects.all()
    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(usuarios.values('id', 'nombre', 'correo_electronico', 'rol'))
    return JsonResponse(data, safe=False)

def lista_cliente(request):
    # Filtrar usuarios con rol "Cliente"
    clientes = Usuario.objects.filter(rol='Cliente')

    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(clientes.values('id', 'nombre', 'correo_electronico', 'rol'))

    return JsonResponse(data, safe=False)

def lista_administradores(request):
    # Filtrar usuarios con rol "Cliente"
    clientes = Usuario.objects.filter(rol='Administrador')

    # Convertir los datos a un formato que se pueda usar en JSON
    data = list(clientes.values('id', 'nombre', 'correo_electronico', 'rol'))

    return JsonResponse(data, safe=False)

def crear_usuario(request):
    if request.method == 'POST':
        rol = request.POST.get('rol')
        if rol == 'Profesional':
            form = UsuarioProfesionalForm(request.POST)
        else:
            form = UsuarioForm(request.POST)
        
        if form.is_valid():
            form.save()
            return redirect('lista_usuarios')  # Redirige a la lista de usuarios
    else:
        form = UsuarioForm()  # Por defecto, usa el formulario básico

    return render(request, 'usuarios/crear_usuario.html', {'form': form})

def usuario_por_id(request, usuario_id):
    usuario = Usuario.objects.get(id=usuario_id)
    data = {
        'id': usuario.id,
        'nombre': usuario.nombre,
        'correo_electronico': usuario.correo_electronico,
        'rol': usuario.rol
    }
    return JsonResponse(data, safe=False)


@require_http_methods(["POST"])
def actualizar_usuario(request, usuario_id):
    usuario = get_object_or_404(Usuario, id=usuario_id)
    form = UsuarioForm(request.POST, instance=usuario)
    
    if form.is_valid():
        form.save()
        return JsonResponse({'status': 'Usuario actualizado correctamente'})
    else:
        return JsonResponse({'errors': form.errors}, status=400)
    

@require_http_methods(["DELETE"])
def eliminar_usuario(request, usuario_id):
    usuario = get_object_or_404(Usuario, id=usuario_id)
    usuario.delete()
    return JsonResponse({'status': 'Usuario eliminado correctamente'})