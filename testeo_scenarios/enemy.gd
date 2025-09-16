extends CharacterBody3D

# Velocidad de animación
@export var anim_speed = 0.2  # segundos por frame

# Frame actual
var frame = 0
var anim_timer = 0.0

# Número de columnas en la fila
const COLUMNS = 3

# Fila que queremos animar (primera fila = 0)
const ROW = 0

func _physics_process(delta: float) -> void:
	# Suspendido en el aire, no aplicamos gravedad ni movimiento
	velocity = Vector3.ZERO
	move_and_slide()

	# Avanzar animación
	anim_timer += delta
	if anim_timer >= anim_speed:
		anim_timer = 0.0
		frame = (frame + 1) % COLUMNS
		update_animation()

func update_animation():
	$Sprite3D.frame = ROW * COLUMNS + frame

func _ready():
	add_to_group("Enemy")
	
