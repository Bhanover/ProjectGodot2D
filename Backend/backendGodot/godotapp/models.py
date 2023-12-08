from django.db import models
from django.utils import timezone

class Usuario(models.Model):
    username = models.CharField(max_length=150, unique=True)
    password = models.CharField(max_length=50)

    def __str__(self):
        return self.username

class EstadisticasJuego(models.Model):
    usuario = models.ForeignKey(Usuario, on_delete=models.CASCADE)
    vidas_actuales = models.IntegerField(default=15)
    vidas_totales_gastadas = models.IntegerField(default=0)
    oro_recolectado = models.IntegerField(default=0)
    oro_recolectado_total =  models.IntegerField(default=0)
    mayor_oro_en_una_partida = models.IntegerField(default=0)
    ultima_actualizacion = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"Estadísticas de {self.usuario.username}"
