from django.contrib import admin
from .models import Usuario

@admin.register(Usuario)
class UsuarioAdmin(admin.ModelAdmin):
    list_display = ('nombre', 'correo_electronico', 'rol')
    search_fields = ('nombre', 'correo_electronico', 'rol')
