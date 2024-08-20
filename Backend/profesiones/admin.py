from django.contrib import admin
from .models import Profesion

@admin.register(Profesion)
class ProfesionAdmin(admin.ModelAdmin):
    list_display = ('nombre_profesion',)
    search_fields = ('nombre_profesion',)
