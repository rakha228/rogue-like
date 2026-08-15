extends Camera2D
@onready var player = %player as Node2D

func _process(delta):
	if is_instance_valid(player):
		global_position = player.global_position
