from django.http import JsonResponse
from .models import *
from django.views.decorators.csrf import csrf_exempt
import json


@csrf_exempt
def registrar_usuario(request):
    if request.method == "POST":
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')

        usuario, created = Usuario.objects.get_or_create(username=username, password=password)
        if created:
            # Crear estadísticas del juego para el usuario
            EstadisticasJuego.objects.create(usuario=usuario, vidas_actuales=15)
            return JsonResponse({"mensaje": "Usuario creado exitosamente"}, status=200)
        else:
            return JsonResponse({"mensaje": "El usuario ya existe"}, status=400)

    return JsonResponse({"mensaje": "Método no permitido"}, status=405)

@csrf_exempt
def iniciar_sesion(request):
    if request.method == "POST":
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')

        try:
            usuario = Usuario.objects.get(username=username)
            if usuario.password == password:
                return JsonResponse({"mensaje": "Inicio de sesión exitoso"}, status=200)
            else:
                return JsonResponse({"mensaje": "Contraseña incorrecta"}, status=401)
        except Usuario.DoesNotExist:
            return JsonResponse({"mensaje": "El usuario no existe"}, status=404)
    
    return JsonResponse({"mensaje": "Método no permitido"}, status=405)

@csrf_exempt
def actualizar_vidas(request):
    if request.method == "POST":
        data = json.loads(request.body)
        username = data.get('username')
        vidas_gastadas = int(data.get('vidas_gastadas', 0))  # Convierte a entero

        try:
            usuario = Usuario.objects.get(username=username)
            estadisticas, created = EstadisticasJuego.objects.get_or_create(usuario=usuario)
            estadisticas.vidas_totales_gastadas += vidas_gastadas
            vidas_restantes = estadisticas.vidas_actuales - estadisticas.vidas_totales_gastadas

            estadisticas.save()
            return JsonResponse({
                "vidas_totales_gastadas": estadisticas.vidas_totales_gastadas,
                "vidas_restantes": vidas_restantes}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({"mensaje": "Usuario no encontrado"}, status=404)

    return JsonResponse({"mensaje": "Método no permitido"}, status=405)
def obtener_vidas(request):
    username = request.GET.get('username')

    try:
        usuario = Usuario.objects.get(username=username)
        estadisticas = EstadisticasJuego.objects.get(usuario=usuario)
        vidas_restantes = estadisticas.vidas_actuales - estadisticas.vidas_totales_gastadas
        return JsonResponse({
            "vidas_restantes": vidas_restantes,
            "vidas_totales_gastadas": estadisticas.vidas_totales_gastadas
        }, status=200)
    except Usuario.DoesNotExist:
        return JsonResponse({"mensaje": "Usuario no encontrado"}, status=404)
