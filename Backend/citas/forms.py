from django import forms
from .models import Cita
from profesiones.models import Profesion


class CrearCitaParaCLienteForm(forms.ModelForm):
    class Meta:
        model = Cita
        fields = ['cliente', 'profesional', 'ubicacion', 'fecha', 'hora_inicio', 'hora_fin', 'estado']


class BuscarProfesionalForm(forms.Form):
    profesion = forms.ModelChoiceField(queryset=Profesion.objects.all(), required=False)
    disponible = forms.BooleanField(required=False, initial=True)