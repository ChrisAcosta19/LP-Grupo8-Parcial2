from django.db import models
from profesionales.models import Profesional

class Ubicacion(models.Model):
    profesional = models.ForeignKey(Profesional, on_delete=models.CASCADE)
    direccion = models.CharField(max_length=255)
