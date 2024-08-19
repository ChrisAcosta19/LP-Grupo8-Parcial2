from django import forms
from .models import Cita

class CrearCitaParaCLienteForm(forms.ModelForm):
    class Meta:
        model = Cita
        fields = ['cliente', 'profesional', 'ubicacion', 'fecha', 'hora_inicio', 'hora_fin', 'estado']