extends Sprite3D

@onready var ChatBox := $"/root/Container/ChatBox"

func _on_area_3d_body_entered(_body):
	ChatBox.show_chat("Elo elo, jest aplikacja zabka wariacie?")

func _on_area_3d_body_exited(_body):
	ChatBox.hide_chat() # Replace with function body.
