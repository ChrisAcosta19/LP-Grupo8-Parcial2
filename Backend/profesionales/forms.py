from django import forms
from .models import Profesional
from .models import Profesion

class ProfesionalForm(forms.ModelForm):
    class Meta:
        model = Profesional
        fields = ['usuario', 'profesion']