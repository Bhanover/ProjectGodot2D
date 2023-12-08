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
        print(vidas_gastadas)
        try:
            usuario = Usuario.objects.get(username=username)
            estadisticas, created = EstadisticasJuego.objects.get_or_create(usuario=usuario)
            estadisticas.vidas_totales_gastadas += vidas_gastadas
            vidas_restantes = estadisticas.vidas_actuales - estadisticas.vidas_totales_gastadas
            print(vidas_gastadas,"-",vidas_restantes)
            estadisticas.save()
            return JsonResponse({
                "vidas_totales_gastadas": estadisticas.vidas_totales_gastadas,
                "vidas_restantes": vidas_restantes}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({"mensaje": "Usuario no encontrado"}, status=404)

    return JsonResponse({"mensaje": "Método no permitido"}, status=405)

@csrf_exempt
def actualizar_estadisticas(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        usuario = Usuario.objects.get(username=data['username'])
        estadisticas, created = EstadisticasJuego.objects.get_or_create(usuario=usuario)

        estadisticas.oro_recolectado = data['oro_recolectado']
        estadisticas.oro_recolectado_total += data['oro_recolectado']
        estadisticas.mayor_oro_en_una_partida = max(estadisticas.mayor_oro_en_una_partida, data['mayor_coins_en_una_partida'])
        estadisticas.save()

        # Incluir los datos actualizados en la respuesta
        return JsonResponse({
            "mensaje": "Estadísticas actualizadas con éxito",
            "oro_recolectado": estadisticas.oro_recolectado,
            "oro_recolectado_total": estadisticas.oro_recolectado_total,
            "mayor_oro_en_una_partida": estadisticas.mayor_oro_en_una_partida
        })
