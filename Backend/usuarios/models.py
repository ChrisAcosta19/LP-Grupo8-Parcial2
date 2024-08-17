from django.db import models

class Usuario(models.Model):
    ROL_CHOICES = [
        ('Cliente', 'Cliente'),
        ('Profesional', 'Profesional'),
        ('Administrador', 'Administrador'),
    ]
    nombre = models.CharField(max_length=100)
    correo_electronico = models.EmailField(unique=True)
    contrasena = models.CharField(max_length=255)
    rol = models.CharField(max_length=20, choices=ROL_CHOICES)

    def __str__(self):
        return self.nombre
