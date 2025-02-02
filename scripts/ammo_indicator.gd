extends AnimatedSprite2D

@onready var weapon_node = $".."
@onready var player_node = $"../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
		# Lock position relative to the parent, but keep rotation at 0.
	global_position = weapon_node.global_position + Vector2(100, 0)
	global_rotation = 0

# Called by input from player
func show_ammo():
	
	var ammo = player_node.ammo
	var max_ammo = player_node.max_ammo
	var ammo_percentage = float(ammo) / max_ammo
	
	if ammo == 0:
		frame = 0
		reveal()
	
	if ammo >= 1:
		frame = int(ammo_percentage * 5) + 1
		reveal()

# Hides the indicator from view after timer ends
func _on_reveal_timer_timeout() -> void:
	hide()

# Reveals the indicator on player's screen and starts timer
func reveal():
	show()
	$RevealTimer.start()
