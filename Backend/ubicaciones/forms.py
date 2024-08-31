from django import forms
from .models import Ubicacion
from profesionales.models import Profesional

class UbicacionForm(forms.ModelForm):
    class Meta:
        model = Ubicacion
        fields = ['profesional', 'direccion']
        widgets = {
            'profesional': forms.Select(),
            'direccion': forms.TextInput(attrs={'placeholder': 'Dirección de la ubicación'}),
        }
