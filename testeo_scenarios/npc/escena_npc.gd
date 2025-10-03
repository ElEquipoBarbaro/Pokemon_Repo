extends CharacterBody3D

const dialogo = preload("res://Dialogs/dialogo.dialogue")


var is_player_close = false
var is_dialogo_active = false

func _process(delta):
	if is_player_close and Input.is_action_just_pressed("interactuar") and not is_dialogo_active:
		await get_tree().create_timer(0.01).timeout  # espera mínima
		var balloon = DialogueManager.show_dialogue_balloon(dialogo)
		balloon.next_action = "interactuar"

func _ready():
	add_to_group("NPC")
	$Area3D.body_entered.connect(_on_body_entered)
	is_player_close = false
	is_dialogo_active = false
	$Area3D.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_started.connect(on_dialogo_started)
	DialogueManager.dialogue_ended.connect(on_dialogo_ended)



func on_dialogo_started(dialogue):
	is_dialogo_active = true
	var player = get_tree().get_nodes_in_group("CHARA")[0]
	if player:
		player.lock_controls()




func on_dialogo_ended(dialogue):
	await get_tree().create_timer(0.2).timeout
	is_dialogo_active = false
	var player = get_tree().get_nodes_in_group("CHARA")[0]
	if player:
		player.unlock_controls()


func _on_body_entered(body):
	if body.is_in_group("CHARA"):
		is_player_close = true

func _on_body_exited(body):
	if body.is_in_group("CHARA"):
		is_player_close = false
