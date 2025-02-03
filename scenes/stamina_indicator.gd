extends AnimatedSprite2D

@onready var player = $"../../Player"
@onready var current_stamina
@onready var is_sprinting: bool

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	is_sprinting = player.is_sprinting
	current_stamina = player.stamina
	
	if is_sprinting:
		frame = round(current_stamina * 10) / 5
		show()
	
	if !is_sprinting:
		hide()
