from django.shortcuts import render, redirect
from django.http import JsonResponse
from .models import Usuario
from .forms import UsuarioForm

#Jefferson Eras
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
        form = UsuarioForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('lista_usuarios')  # Redirige a la lista de usuarios
    else:
        form = UsuarioForm()
    return render(request, 'usuarios/crear_usuario.html', {'form': form})
