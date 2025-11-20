extends Control

signal textbox_closed

@export var enemy: Resource = null

var current_player_health: int = 100
var current_enemy_health: int = 100
var is_defending: bool = false

var _message_queue: Array = []
var _is_showing_message: bool = false
var _auto_timer: Timer = null

func _ready() -> void:
	_auto_timer = Timer.new()
	_auto_timer.wait_time = 1.5
	_auto_timer.one_shot = true
	_auto_timer.timeout.connect(_on_message_timeout)
	add_child(_auto_timer)

	if enemy == null:
		push_error("Battle: Debes asignar un Resource BaseEnemy en el Inspector.")
		return

	$Actions/Attack.pressed.connect(Callable(self, "_on_Attack_pressed"))
	$Actions/Defend.pressed.connect(Callable(self, "_on_Defend_pressed"))
	$Actions/Run.pressed.connect(Callable(self, "_on_Run_pressed"))

	if State != null:
		current_player_health = State.current_health
		current_enemy_health = enemy.health
		set_health($PlayerPanel/PlayerData/PlayerHP, current_player_health, State.max_health)
	else:
		current_player_health = 35
		current_enemy_health = enemy.health
		set_health($PlayerPanel/PlayerData/PlayerHP, current_player_health, current_player_health)

	set_health($EnemyContainer/EnemyHP, current_enemy_health, enemy.health)
	$EnemyContainer/Enemy.texture = enemy.texture

	$Textbox.hide()
	$Actions.hide()

	display_text("¡Un %s aparece!" % enemy.name.to_upper())


# ---------------------------
# Mensajes secuenciales auto
# ---------------------------

func display_text(text: String) -> void:
	_message_queue.append(text)
	if not _is_showing_message:
		_show_next_message()

func _show_next_message() -> void:
	if _message_queue.size() == 0:
		_is_showing_message = false
		$Textbox.hide()
		$Actions.show()
		return

	var raw = _message_queue.pop_front()
	var msg: String = str(raw)

	$Actions.hide()
	$Textbox.show()
	$Textbox/Label.text = msg
	_is_showing_message = true

	if _auto_timer:
		_auto_timer.start()

func _on_message_timeout() -> void:
	_show_next_message()


# ---------------------------
# Salud
# ---------------------------

func set_health(progress_bar: ProgressBar, health: int, max_health: int) -> void:
	progress_bar.value = health
	progress_bar.max_value = max_health
	var lbl = progress_bar.get_node_or_null("Label")
	if lbl and lbl is Label:
		(lbl as Label).text = "HP: %d/%d" % [health, max_health]


# ---------------------------
# Turnos y acciones
# ---------------------------

func enemy_turn() -> void:
	display_text("%s ataca ferozmente!" % enemy.name)

	if is_defending:
		is_defending = false
		display_text("Te has defendido exitosamente!")
	else:
		current_player_health = max(0, current_player_health - enemy.damage)
		set_health($PlayerPanel/PlayerData/PlayerHP, current_player_health, State.max_health if State != null else current_player_health)
		display_text("%s infligió %d pts de daño!" % [enemy.name, enemy.damage])


func _on_Run_pressed() -> void:
	display_text("¡Escapas exitosamente!")
	display_text("Fin del combate.")
	_call_when_queue_empty_quit()


func _on_Attack_pressed() -> void:
	display_text("¡Atacas velozmente con tu espada!")
	var player_damage = State.damage if State != null else 0
	current_enemy_health = max(0, current_enemy_health - player_damage)
	set_health($EnemyContainer/EnemyHP, current_enemy_health, enemy.health)
	display_text("Hiciste %d pts de daño!" % player_damage)

	if current_enemy_health == 0:
		display_text("%s fue derrotado!" % enemy.name)
		_call_when_queue_empty_quit()
		return

	enemy_turn()

func _on_Defend_pressed() -> void:
	is_defending = true
	display_text("¡Te preparas para defenderte!")
	enemy_turn()


# ---------------------------
# Utilidades
# ---------------------------

func _call_when_queue_empty_quit() -> void:
	var checker = Timer.new()
	checker.wait_time = 0.2
	checker.one_shot = false
	checker.autostart = true
	add_child(checker)
	checker.timeout.connect(Callable(self, "_on_quit_checker_timeout"))
	set_meta("quit_checker", checker)

func _on_quit_checker_timeout() -> void:
	if _message_queue.size() == 0 and not _is_showing_message:
		var t = get_meta("quit_checker")
		if t and t is Timer:
			t.stop()
			t.queue_free()
			remove_meta("quit_checker")
		get_tree().quit()
