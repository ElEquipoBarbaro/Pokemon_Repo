extends CharacterBody3D

const SPEED = 2.0
const JUMP_VELOCITY = 4.5
@export var frame := 0
@export var animation_row := 0
const arriba := Vector2(0, -1)
const abajo := Vector2(0, 1)
const izquierda := Vector2(-1, 0)
const derecha := Vector2(1, 0)

var anim_timer := 0.0
var anim_speed := 0.16

# --- Cámara: NO asumimos $Camera3D ---
@export var camera_path: NodePath          # así la asignas en el editor
@onready var cam: Camera3D = get_node_or_null(camera_path) as Camera3D

var camera_original_position := Vector3.ZERO
var is_transitioning := false

# Congelar controles durante diálogos
var controls_locked := false
func lock_controls(): controls_locked = true
func unlock_controls(): controls_locked = false

# Escena de combate
var combate_scene: PackedScene = load("res://combate.tscn")

func _ready():
	add_to_group("CHARA")
	if cam:
		camera_original_position = cam.position
	else:
		push_warning("No se encontró la cámara. Asigna 'camera_path' en el inspector.")

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
	if not cam:
		push_warning("No hay cámara asignada, se omite transición.")
		_go_to_combat()
		return

	is_transitioning = true
	var tween = create_tween().set_parallel(true)
	var zoom_out_position = camera_original_position + Vector3(0, 0.8, 1.2)
	tween.tween_property(cam, "position", zoom_out_position, 0.2)
	await tween.finished
	await get_tree().create_timer(0.1).timeout

	var zoom_in_position = camera_original_position + Vector3(0, -0.2, -0.4)
	var tween2 = create_tween()
	tween2.tween_property(cam, "position", zoom_in_position, 0.25)
	await tween2.finished

	await create_screen_fade()
	cam.position = camera_original_position
	_go_to_combat()

func _go_to_combat():
	get_tree().paused = true
	var combate_instance = combate_scene.instantiate()
	get_tree().current_scene.add_child(combate_instance)

func create_screen_fade():
	var fade_overlay := ColorRect.new()
	fade_overlay.color = Color(0, 0, 0, 0)
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fade_overlay.name = "FadeOverlay"
	get_tree().current_scene.add_child(fade_overlay)
	var fade_tween = create_tween()
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.8)
	await fade_tween.finished

func _physics_process(delta: float) -> void:
	if get_tree().paused or is_transitioning or controls_locked:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider_node = collision.get_collider()
		if collider_node and collider_node.is_in_group("Enemy"):
			camera_transition_effect()
			break
