extends AnimatedSprite2D

# Reference the parent node (player)
@onready var parent_node = $"../../Player"

func _process(_delta):
	
	global_rotation = 0
	
	update_health_bar()

func update_health_bar():
	
	# Pull health from parent player node
	var health = parent_node.health
	
	# Choose sprite frame number 1-10 (closest int to a tenth of health %)
	frame = round(health / 10)
	
