from django import forms
from .models import HorarioDisponible

class HorarioDisponibleForm(forms.ModelForm):
    class Meta:
        model = HorarioDisponible
        fields = ['fecha', 'hora_inicio', 'hora_fin']