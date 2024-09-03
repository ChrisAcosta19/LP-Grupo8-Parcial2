from django.db import models
# from usuarios.models import Usuario
from profesionales.models import Profesional


class Ubicacion(models.Model):
    direccion = models.CharField(max_length=255)
    profesional = models.ForeignKey(Profesional, on_delete=models.CASCADE)