extends CharacterBody3D

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
@export var frame = 0
@export var animation_row = 0
const arriba = Vector2(0,-1)
const abajo = Vector2(0,1)
const izquierda = Vector2(-1,0)
const derecha = Vector2(1,0)
var anim_timer = 0.0
var anim_speed = 0.16  # segundos por frame

# Variables para el efecto de cámara
var camera_original_position: Vector3
var is_transitioning = false

# Cargar la escena de combate
var combate_scene: PackedScene = load("res://combate.tscn")

func _ready():
	# Guardar la posición original de la cámara
	camera_original_position = $Camera3D.position

func update_animation_row(input_dir: Vector2):
	if input_dir == abajo:
		animation_row = 0
	elif input_dir == izquierda:
		animation_row = 1
	elif input_dir == derecha:
		animation_row = 2
	elif input_dir == arriba:
		animation_row = 3

func update_animation():
	$Sprite3D.frame = frame + animation_row * 4

func camera_transition_effect():
	is_transitioning = true
	
	# Crear el tween para el efecto de cámara
	var tween = create_tween()
	tween.set_parallel(true)  # Permite múltiples animaciones simultáneas
	
	# Zoom out LIGERO - alejar la cámara solo un poco
	var zoom_out_position = camera_original_position + Vector3(0, 0.8, 1.2)
	tween.tween_property($Camera3D, "position", zoom_out_position, 0.2)
	
	# Pausa más corta
	await tween.finished
	await get_tree().create_timer(0.1).timeout
	
	# Zoom in SUTIL - acercar solo ligeramente
	var zoom_in_position = camera_original_position + Vector3(0, -0.2, -0.4)
	var tween2 = create_tween()
	tween2.tween_property($Camera3D, "position", zoom_in_position, 0.25)
	
	await tween2.finished
	
	# Efecto de pantalla en negro/fade IN únicamente
	create_screen_fade()
	
	# Esperar a que termine el fade in
	await get_tree().create_timer(0.8).timeout  # Tiempo del fade in
	
	# Restaurar posición original
	$Camera3D.position = camera_original_position
	
	# AHORA pausar el juego y cargar la escena de combate
	get_tree().paused = true
	var combate_instance = combate_scene.instantiate()
	get_tree().current_scene.add_child(combate_instance)

func create_screen_fade():
	# Crear un ColorRect negro para el efecto fade
	var fade_overlay = ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)  # Negro transparente
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.name = "FadeOverlay"  # Nombre para poder encontrarlo después si es necesario
	
	# Agregarlo a la escena
	get_tree().current_scene.add_child(fade_overlay)
	
	# Crear tween SOLO para fade in (sin fade out)
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.8)  # Fade in a negro completo
	
	await fade_tween.finished
	# El overlay se queda en pantalla para que puedas hacer fade out después

func _physics_process(delta: float) -> void:
	if get_tree().paused or is_transitioning:
		return  # si está pausado o en transición no procesamos nada
	
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Movimiento
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if input_dir != Vector2.ZERO:
		update_animation_row(input_dir)
		anim_timer += delta
		if anim_timer >= anim_speed:
			anim_timer = 0.0
			frame = (frame + 1) % 4
			update_animation()
		
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	# Detectar colisiones con enemigos
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider_node = collision.get_collider()
		if collider_node and collider_node.is_in_group("Enemy"):
			# Iniciar efecto de cámara (SIN pausar todavía)
			camera_transition_effect()
			break
