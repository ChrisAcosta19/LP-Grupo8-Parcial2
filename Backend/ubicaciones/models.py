from django.db import models
from usuarios.models import Usuario


class Ubicacion(models.Model):
    direccion = models.CharField(max_length=255)
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE, db_column='usuario_id')

    def __str__(self):
        return f"{self.direccion} ({self.usuario.nombre})"