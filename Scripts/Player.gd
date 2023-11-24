extends KinematicBody2D

const moveSpeed = 25;
const maxSpeed = 50;

const jumpHeight = 300;
const up = Vector2(0, -1)
const gravity = 15
onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
var motion = Vector2()

func _physics_process(delta):
	motion.y += gravity
	var friction = false
	
	# Movimiento horizontal
	if Input.is_action_pressed("ui_right"):
		sprite.flip_h = true
		animationPlayer.play("Walk")
		motion.x = min(motion.x + moveSpeed, maxSpeed)
		
	elif Input.is_action_pressed("ui_left"):
		sprite.flip_h = false
		animationPlayer.play("Walk")
		motion.x = max(motion.x - moveSpeed, -maxSpeed)
		
	else:
		animationPlayer.play("Idle")
		friction = true
	
	# Salto
	if is_on_floor() and Input.is_action_pressed("ui_accept"):
		motion.y = -jumpHeight
	
	# Fricción
	if friction:
		if is_on_floor():
			motion.x = lerp(motion.x, 0, 0.5)
		else:
			motion.x = lerp(motion.x, 0, 0.01)
	
	# Aplicar movimiento
	motion = move_and_slide(motion, up)

func add_coin():
	var canvasLayer = get_tree().get_root().find_node("CanvasLayer",true,false);
	canvasLayer.handleCoinCollected()

#Damage
func _on_Splites_body_entered(body):
	if body.get_name() == "Player":
		print("nos hemos pinchado")
		get_tree().reload_current_scene()
	
func _loseLife():
	print("Nos hemos pinchado ,perdemos vida")
	get_tree().reload_current_scene()
