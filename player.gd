extends CharacterBody2D

class_name Player

@export var speed = 600 # How fast the player will move (pixels/sec).
@export var fire_cooldown: float = 0.1
@export var max_health = 100
@export var max_ammo = 30

@onready var health = max_health
@onready var ammo = max_ammo

var last_fire_time: float = -fire_cooldown
var bullet = preload("res://bullet.tscn")
var bullet_speed = 4400

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var input_vector = Vector2.ZERO # The player's movement vector.

	# Movement Controls
	if Input.is_action_pressed("move_right"):
		input_vector.x += 1
	if Input.is_action_pressed("move_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("move_down"):
		input_vector.y += 1
	if Input.is_action_pressed("move_up"):
		input_vector.y -= 1

	# Normalize to prevent faster diagonal movement and apply speed
	if input_vector != Vector2.ZERO:
		velocity = input_vector.normalized() * speed
		$PlayerSprite.play("walk")
	else:
		velocity = Vector2.ZERO
		$PlayerSprite.stop()

	# Update movement using velocity
	move_and_slide()

	# Rotate the player to face the mouse
	var mouse_position = get_global_mouse_position()
	look_at(mouse_position)

	# Weapon Controls
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
		
		# Calculate the direction vector
		var direction = Vector2(cos(bullet_instance.rotation), sin(bullet_instance.rotation))
		
		# Set bullet velocity
		bullet_instance.linear_velocity = direction * bullet_speed
		
		# Add the bullet to the scene
		get_tree().get_root().add_child(bullet_instance)
		
		# Take a bullet out of player's mag
		ammo -= 1
	
	elif  ammo == 0:
		$WeaponSprite/AmmoIndicator.show_ammo()

func reload():
	# Add player reload animation (and time delay) here later
	ammo = max_ammo
	$WeaponSprite/AmmoIndicator.show_ammo()

func start_sprinting():
	speed = 1000

func stop_sprinting():
	speed = 600

func bullet_impact():
	take_damage(10)
	
func take_damage(damage: int):
	health -= damage
	if health <= 0:
		die()

func die():
	print("ur dead")
	queue_free()
