# usuarios/forms.py
from django import forms
from .models import Usuario
from profesionales.models import Profesional, Profesion

class UsuarioForm(forms.ModelForm):
    class Meta:
        model = Usuario
        fields = ['nombre', 'correo_electronico', 'contrasena', 'rol']


class UsuarioProfesionalForm(forms.ModelForm):
    profesion = forms.ModelChoiceField(queryset=Profesion.objects.all(), required=True)

    class Meta:
        model = Usuario
        fields = ['nombre', 'correo_electronico', 'contrasena', 'rol']  # Añade otros campos necesarios

    def save(self, commit=True):
        usuario = super().save(commit=False)
        if commit:
            usuario.save()
            if usuario.rol == 'Profesional':
                profesion = self.cleaned_data['profesion']
                Profesional.objects.create(usuario=usuario, profesion=profesion)
        return usuario
