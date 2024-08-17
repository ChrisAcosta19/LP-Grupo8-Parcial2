from django.db import models
from usuarios.models import Usuario
from profesionales.models import Profesional
from ubicaciones.models import Ubicacion

class Cita(models.Model):
    ESTADO_CHOICES = [
        ('Agendada', 'Agendada'),
        ('Reprogramada', 'Reprogramada'),
        ('Cancelada', 'Cancelada'),
    ]
    cliente = models.ForeignKey(Usuario, on_delete=models.CASCADE, limit_choices_to={'rol': 'Cliente'})
    profesional = models.ForeignKey(Profesional, on_delete=models.CASCADE)
    ubicacion = models.ForeignKey(Ubicacion, on_delete=models.CASCADE, default=None)
    fecha = models.DateField(default=None)
    hora_inicio = models.TimeField(default=None)
    hora_fin = models.TimeField(default=None)
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='Agendada')

    def __str__(self):
        return f"Cita con {self.profesional.usuario.nombre} el {self.fecha_hora} - Estado: {self.estado}"
