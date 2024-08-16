# Generated by Django 5.1 on 2024-08-16 16:57

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('profesionales', '0001_initial'),
        ('usuarios', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Cita',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fecha_hora', models.DateTimeField()),
                ('estado', models.CharField(choices=[('Agendada', 'Agendada'), ('Reprogramada', 'Reprogramada'), ('Cancelada', 'Cancelada')], default='Agendada', max_length=15)),
                ('cliente', models.ForeignKey(limit_choices_to={'rol': 'Cliente'}, on_delete=django.db.models.deletion.CASCADE, to='usuarios.usuario')),
                ('profesional', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='profesionales.profesional')),
            ],
        ),
    ]
