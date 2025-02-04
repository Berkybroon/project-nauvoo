extends AnimatedSprite2D

@onready var player = $"../../Player"
@onready var current_stamina
@onready var is_sprinting: bool

# Variables for delay logic
var time_since_stopped_sprinting: float = 0.0
var hide_delay: float = 1.5  # Delay in seconds (adjust as needed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	is_sprinting = player.is_sprinting
	current_stamina = player.stamina
	
	if is_sprinting:
		# Player is sprinting: show the sprite and reset the timer
		frame = round(current_stamina / 5)
		show()
		time_since_stopped_sprinting = 0.0  # Reset the counter
	else:
		# Player is not sprinting: start counting the time
		if visible:
			time_since_stopped_sprinting += delta  # Increment the counter by delta time
			
			# Check if the delay has passed
			if time_since_stopped_sprinting >= hide_delay:
				hide()  # Hide the sprite after the delay
				time_since_stopped_sprinting = 0.0  # Reset the counter
