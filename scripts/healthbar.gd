extends AnimatedSprite2D

# Reference the parent node (player)
@onready var parent_node = $".."

func _process(_delta):
	
	# Lock position relative to the parent, but keep rotation at 0.
	global_position = parent_node.global_position + Vector2(0, 150)
	global_rotation = 0
	
	update_health_bar()

func update_health_bar():
	
	# Pull health from parent player node
	var health = parent_node.health
	
	# Choose sprite frame number 1-10 (closest int to a tenth of health %)
	frame = round(health / 10)
	
