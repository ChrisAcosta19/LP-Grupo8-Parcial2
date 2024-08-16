from django.db import models
from profesionales.models import Profesional

class HorarioDisponible(models.Model):
    profesional = models.ForeignKey(Profesional, on_delete=models.CASCADE)
    fecha = models.DateField()
    hora_inicio = models.TimeField()
    hora_fin = models.TimeField()

    def __str__(self):
        return f"{self.profesional.usuario.nombre} - {self.fecha} de {self.hora_inicio} a {self.hora_fin}"
