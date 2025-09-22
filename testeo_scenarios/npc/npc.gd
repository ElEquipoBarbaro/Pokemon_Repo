extends CharacterBody3D

func _ready():
	add_to_group("NPC")
	$Area3D.body_entered.connect(_on_body_entered)
	$Area3D.body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("CHARA"):
		print("Jugador se acercó al NPC")

func _on_body_exited(body):
	if body.is_in_group("CHARA"):
		print("Jugador se alejó del NPC")
