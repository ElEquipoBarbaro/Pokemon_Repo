extends CharacterBody3D

const dialogo = preload("res://Dialogs/dialogo.dialogue")


var is_player_close = false
var is_dialogo_active = false

func _process(delta):
	if is_player_close and Input.is_action_just_pressed("ui_accept") and not is_dialogo_active:
		DialogueManager.show_dialogue_balloon(dialogo)

func _ready():
	add_to_group("NPC")
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)
	DialogueManager.dialogue_started.connect(on_dialogo_started)
	DialogueManager.dialogue_ended.connect(on_dialogo_ended)



func on_dialogo_started(dialogue):
	is_dialogo_active = true	

func on_dialogo_ended(dialogue):
	is_dialogo_active = false

func _on_body_entered(body):
	is_player_close = true
	#if body.is_in_group("CHARA"):
	#	print("Jugador se acercó al NPC")
	#	# Mostrar el diálogo usando el manager con balloon
	#	DialogueManager.show_dialogue_balloon(dialogo)

func _on_body_exited(body):
	is_player_close = false	
	#if body.is_in_group("CHARA"):
	#	print("Jugador se alejó del NPC")
