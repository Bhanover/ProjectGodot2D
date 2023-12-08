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
        print("esto son las coins",data['oro_recolectado'],"-",data['mayor_coins_en_una_partida'])

        # Incluir los datos actualizados en la respuesta
        return JsonResponse({
            "mensaje": "Estadísticas actualizadas con éxito",
            "oro_recolectado": estadisticas.oro_recolectado,
            "oro_recolectado_total": estadisticas.oro_recolectado_total,
            "mayor_oro_en_una_partida": estadisticas.mayor_oro_en_una_partida
        })
@csrf_exempt
def sumar_vida(request):
    if request.method == "POST":
        data = json.loads(request.body)
        username = data.get('username')
        
        try:
            usuario = Usuario.objects.get(username=username)
            estadisticas, created = EstadisticasJuego.objects.get_or_create(usuario=usuario)
            estadisticas.vidas_actuales += 1  # Sumar una vida
            vidas_restantes = estadisticas.vidas_actuales - estadisticas.vidas_totales_gastadas

            estadisticas.save()
            return JsonResponse({
                "mensaje": "Vida añadida con éxito",
                "vidas_actuales": vidas_restantes
            }, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({"mensaje": "Usuario no encontrado"}, status=404)

    return JsonResponse({"mensaje": "Método no permitido"}, status=405)
@csrf_exempt
def obtener_vidas_actuales(request):
    if request.method == "GET":
        username = request.GET.get('username')

        if not username:
            return JsonResponse({"mensaje": "Nombre de usuario no proporcionado"}, status=400)

        try:
            usuario = Usuario.objects.get(username=username)
            estadisticas = EstadisticasJuego.objects.get(usuario=usuario)
            vidas_restantes = estadisticas.vidas_actuales - estadisticas.vidas_totales_gastadas
 
            return JsonResponse({"vidas_actuales": vidas_restantes}, status=200)
        except Usuario.DoesNotExist:
            return JsonResponse({"mensaje": "Usuario no encontrado"}, status=404)
        except EstadisticasJuego.DoesNotExist:
            return JsonResponse({"mensaje": "Estadísticas no encontradas"}, status=404)

    return JsonResponse({"mensaje": "Método no permitido"}, status=405)
