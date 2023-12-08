# AjusteVolumen.gd

extends Panel

# Referencias a los nodos de audio
onready var music_player = get_node("/root/Mundo/MusicMundo")
onready var damage_sound = get_node("/root/Mundo/DamageSound")
onready var death_sound = get_node("/root/Mundo/DeathSound")

# Referencia al deslizador de volumen y al botón de silencio
onready var slider_volumen = $SliderVolumen
onready var boton_silencio = $BotonSilencio

# Valores iniciales
var volumen_actual = 0.5  # 50% del volumen
var esta_silenciado = false

func _ready():
	slider_volumen.value = volumen_actual * 100  # Establecer el valor del deslizador
	actualizar_volumen()

func _on_SliderVolumen_value_changed(valor):
	volumen_actual = valor / 100.0
	actualizar_volumen()

func _on_BotonSilencio_pressed():
	esta_silenciado = !esta_silenciado
	actualizar_volumen()

func actualizar_volumen():
	var volumen_final = esta_silenciado ? 0.0 : volumen_actual
	music_player.volume_db = linear2db(volumen_final)
	damage_sound.volume_db = linear2db(volumen_final)
	death_sound.volume_db = linear2db(volumen_final)

# Función auxiliar para convertir volumen lineal a decibelios
func linear2db(linear):
	return 20.0 * log(linear) / log(10.0)
