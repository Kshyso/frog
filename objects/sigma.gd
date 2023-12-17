extends Area3D

@onready var resource = load("res://dialogs/sigma.dialogue")

func _on_body_entered(_body: CharacterBody3D):
	DialogueManager.show_example_dialogue_balloon(resource, "start")
