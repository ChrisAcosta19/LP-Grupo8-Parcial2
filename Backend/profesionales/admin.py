from django.contrib import admin
from .models import Profesional

@admin.register(Profesional)
class ProfesionalAdmin(admin.ModelAdmin):
    list_display = ('usuario', 'profesion')
    search_fields = ('usuario__nombre', 'profesion__nombre_profesion')
