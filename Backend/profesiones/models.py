from django.db import models

class Profesion(models.Model):
    nombre_profesion = models.CharField(max_length=100)

    def __str__(self):
        return self.nombre_profesion
