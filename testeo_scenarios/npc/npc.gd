extends CharacterBody3D

const DIALOG_RES := "res://Dialogs/dialogo.dialogue"
const START_NODE := "inicio"

@onready var DM := get_node_or_null("/root/DialogueManager") # autoload

var _original_ui_accept_events: Array = []
var _active_balloon: Node = null
var _player: Node = null
var _dialogue_active := false

func _ready() -> void:
	add_to_group("NPC")

	# Asegurar Area3D presente y configurado
	var area := get_node_or_null("Area3D")
	if area == null:
		area = Area3D.new()
		area.name = "Area3D"
		add_child(area)
		# Colision: esfera simple
		var cs := CollisionShape3D.new()
		var shp := SphereShape3D.new()
		shp.radius = 1.5
		cs.shape = shp
		area.add_child(cs)
	
	# Monitoring ON
	area.monitoring = true
	area.monitorable = true
	# Por defecto, el Player suele estar en capa 1. Hacemos que el Area detecte capa 1.
	area.collision_layer = 0                       # el área NO "pega", solo detecta
	area.collision_mask = 0
	area.set_collision_mask_value(1, true)         # detectar bodies en layer 1

	# Conectar señales
	if not area.body_entered.is_connected(_on_body_entered):
		area.body_entered.connect(_on_body_entered)
	if not area.body_exited.is_connected(_on_body_exited):
		area.body_exited.connect(_on_body_exited)

	# Verificar DialogueManager autoload
	if DM == null:
		push_error("NPC: No se encontró /root/DialogueManager (Proyecto → Autoload).")
	else:
		if DM.has_signal("dialogue_ended") and not DM.dialogue_ended.is_connected(_on_dialogue_ended):
			DM.dialogue_ended.connect(_on_dialogue_ended)
		if DM.has_signal("event") and not DM.event.is_connected(_on_dialogue_event):
			DM.event.connect(_on_dialogue_event)

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("CHARA") or _dialogue_active:
		return

	_player = body
	_dialogue_active = true
	print("[NPC] Jugador se acercó al NPC")

	# Congelar jugador
	if _player.has_method("lock_controls"): 
		_player.lock_controls()
	if _player.has_method("set_physics_process"): 
		_player.set_physics_process(false)
	if "velocity" in _player: 
		_player.velocity = Vector3.ZERO

	# Remapear ui_accept → TAB
	_rebind_ui_accept_to_tab()

	# Cargar y mostrar diálogo
	_show_dialogue()

func _show_dialogue() -> void:
	# Cargar diálogo
	var dlg := load(DIALOG_RES)
	if dlg == null:
		push_error("[NPC] No se pudo cargar " + DIALOG_RES)
		_end_dialogue()
		return
		
	if DM == null or not DM.has_method("show_dialogue_balloon"):
		push_error("[NPC] DialogueManager no disponible o sin show_dialogue_balloon.")
		_end_dialogue()
		return

	# Mostrar balloon
	_active_balloon = DM.show_dialogue_balloon(dlg, START_NODE)
	if _active_balloon == null:
		push_error("[NPC] show_dialogue_balloon devolvió null (¿existe '~ " + START_NODE + "' en el .dialogue?).")
		_end_dialogue()
		return

	_active_balloon.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Configurar foco si es un Control
	if _active_balloon is Control:
		var c := _active_balloon as Control
		c.focus_mode = Control.FOCUS_ALL
		c.call_deferred("grab_focus")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("CHARA"):
		print("[NPC] Jugador se alejó del NPC")
		# Solo terminar diálogo si no está activo
		if not _dialogue_active:
			_end_dialogue()

func _on_dialogue_ended(resource: DialogueResource) -> void:
	print("[NPC] Diálogo terminado por DialogueManager")
	_end_dialogue()

func _end_dialogue() -> void:
	if not _dialogue_active:
		return
		
	_dialogue_active = false
	_restore_ui_accept()
	
	if _player:
		if _player.has_method("unlock_controls"): 
			_player.unlock_controls()
		if _player.has_method("set_physics_process"): 
			_player.set_physics_process(true)
	
	_active_balloon = null
	_player = null
	print("[NPC] Diálogo cerrado y controles restaurados.")

func _on_dialogue_event(event_name: String) -> void:
	match event_name:
		"hablar":
			print("[NPC] El jugador eligió HABLAR")
		"desafiar":
			print("[NPC] El jugador eligió DESAFIAR")
		_:
			print("[NPC] Evento desconocido:", event_name)

# --- Remapeo temporal ui_accept→TAB ---
func _rebind_ui_accept_to_tab() -> void:
	if _original_ui_accept_events.is_empty():
		_original_ui_accept_events = InputMap.action_get_events("ui_accept")
	
	InputMap.action_erase_events("ui_accept")
	var ev := InputEventKey.new()
	ev.keycode = KEY_TAB
	InputMap.action_add_event("ui_accept", ev)
	print("[NPC] Remapeado ui_accept a TAB")

func _restore_ui_accept() -> void:
	if not _original_ui_accept_events.is_empty():
		InputMap.action_erase_events("ui_accept")
		for ev in _original_ui_accept_events:
			InputMap.action_add_event("ui_accept", ev)
		_original_ui_accept_events.clear()
		print("[NPC] Restaurado ui_accept original")

# Método para forzar el fin del diálogo (útil para debugging)
func force_end_dialogue() -> void:
	if _active_balloon:
		_active_balloon.queue_free()
	_end_dialogue()
