extends CharacterBody2D

class_name Player

@export var speed = 600 # How fast the player will move (pixels/sec).
@export var sprint_speed = 1000 # Movement speed while sprinting (pixels/sec).
@export var fire_cooldown: float = 0.1
@export var max_health = 100
@export var max_ammo = 30
@export var max_stamina = 100.0

@onready var stamina = max_stamina
@onready var health = max_health
@onready var ammo = max_ammo
@onready var is_sprinting: bool = false

var last_fire_time: float = -fire_cooldown

var bullet = preload("res://scenes/bullet.tscn")
var bullet_speed = 4400

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	var input_vector = Vector2.ZERO # The player's movement vector.
	var mouse_position = get_global_mouse_position()
	var inventory_open = $"../HUD/InventoryGrid".visible

	# Movement Controls
	if !inventory_open:

		look_at(mouse_position)

		if Input.is_action_pressed("move_right"):
			input_vector.x += 1
		if Input.is_action_pressed("move_left"):
			input_vector.x -= 1
		if Input.is_action_pressed("move_down"):
			input_vector.y += 1
		if Input.is_action_pressed("move_up"):
			input_vector.y -= 1

	var current_speed = sprint_speed if is_sprinting else speed

	# Normalize to prevent faster diagonal movement and apply speed
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * current_speed
		$PlayerSprite.play("walk")
	else:
		velocity = Vector2.ZERO
		$PlayerSprite.stop()

	# Update movement using velocity
	move_and_slide()

	# Weapon Controls (disabled while the inventory is open so menu clicks don't shoot)
	if !inventory_open:
		if Input.is_action_just_pressed("fire_primary"):
			fire()

		if Input.is_action_just_pressed("reload"):
			reload()

	if Input.is_action_pressed("mag_check"):
		$WeaponSprite/AmmoIndicator.show_ammo()


	# Movement Controls
	if Input.is_action_just_pressed("sprint"):
		start_sprinting()

	if Input.is_action_just_released("sprint"):
		stop_sprinting()

	# Sprinting / stamina logic (only drains while actually moving)
	if is_sprinting && input_vector != Vector2.ZERO:
		stamina -= (delta * 20)
	if !is_sprinting && stamina < max_stamina:
		stamina = min(stamina + (delta * 10), max_stamina)
	if stamina <= 0:
		stamina = 0
		stop_sprinting()


func fire():
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time >= last_fire_time + fire_cooldown && ammo > 0:
		last_fire_time = current_time
		var bullet_instance = bullet.instantiate()

		# Gunshot animation
		$WeaponSprite.play()

		# Set bullet initial position and rotation
		bullet_instance.position = $WeaponSprite/PlayerMuzzle.global_position
		bullet_instance.rotation = rotation
		bullet_instance.speed = bullet_speed

		# Calculate the direction vector
		var direction = Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation))

		# Set bullet velocity
		bullet_instance.linear_velocity = direction * bullet_speed

		# Add the bullet to the current scene so it is cleaned up on scene change
		get_tree().get_current_scene().add_child(bullet_instance)

		# Take a bullet out of player's mag
		ammo -= 1

	elif ammo == 0:
		$WeaponSprite/AmmoIndicator.show_ammo()

func reload():
	# Add player reload animation (and time delay) here later
	ammo = max_ammo
	$WeaponSprite/AmmoIndicator.show_ammo()

func start_sprinting():
	# Can't start a sprint with an empty stamina bar
	if stamina <= 0:
		return
	is_sprinting = true

func stop_sprinting():
	is_sprinting = false

func heal(amount: int):
	health = min(health + amount, max_health)

func bullet_impact():
	take_damage(10)

func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	# Stop processing so nothing touches the player while the scene swaps out
	set_physics_process(false)
	get_tree().change_scene_to_file.call_deferred("res://scenes/main_menu.tscn")

func extract():

	# Send player inventory to global variables so they can be accessed by menus later
	var inventory = $"../HUD/Inventory".get_items()
	var inventory_slots = $"../HUD/Inventory".max_slots
	global.set_inventory(inventory)
	global.set_max_inventory_slots(inventory_slots)

	# Switch to post-raid summary
	get_tree().change_scene_to_file("res://scenes/post_raid_summary.tscn")
