from django.db import models
from usuarios.models import Usuario
from profesiones.models import Profesion


class Profesional(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    profesion = models.ForeignKey(Profesion, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.usuario.nombre} - {self.profesion.nombre_profesion}"
