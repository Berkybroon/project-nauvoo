extends Area2D

@onready var extract_timer = $Timer

var player

func _on_body_entered(body: Node2D) -> void:
	player = body
	extract_timer.start()

func _on_body_exited(body: Node2D) -> void:
	player = null
	extract_timer.stop()

func _on_timer_timeout() -> void:
	player.extract()
	extract_timer.stop()

func _process(delta: float) -> void:
	if player:
		player.update_extract_timer(extract_timer.time_left)
