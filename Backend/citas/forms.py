from django import forms
from .models import Cita
from profesiones.models import Profesion
from profesionales.models import Profesional


class CrearCitaParaCLienteForm(forms.ModelForm):
    class Meta:
        model = Cita
        fields = ['cliente', 'profesional', 'ubicacion', 'fecha', 'hora_inicio', 'hora_fin', 'estado']


class BuscarProfesionalForm(forms.Form):
    profesion = forms.ModelChoiceField(queryset=Profesion.objects.all(), required=False)
    disponible = forms.BooleanField(required=False, initial=True)

class BuscarHorariosPorProfesional(forms.Form):
    profesion = forms.ModelChoiceField(queryset=Profesion.objects.all(), required=False, label="Profesión")
    profesional = forms.ModelChoiceField(queryset=Profesional.objects.all(), required=False, label="Profesional")
