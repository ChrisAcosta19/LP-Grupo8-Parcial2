from django import forms
from .models import Cita

class CrearCitaParaCLienteForm(forms.ModelForm):
    class Meta:
        model = Cita
        fields = ['cliente', 'profesional', 'ubicacion', 'fecha', 'hora_inicio', 'hora_fin', 'estado']


from profesiones.models import Profesion

class BuscarProfesionalForm(forms.Form):
    profesion = forms.ModelChoiceField(queryset=Profesion.objects.all(), required=False)
    disponible = forms.BooleanField(required=False, initial=True)