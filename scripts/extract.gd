extends Area2D

@onready var extract_timer = $Timer

var player

func _on_body_entered(body: Node2D) -> void:
	player = body
	extract_timer.start()
	$"../HUD/ExtractLabel1".show()
	$"../HUD/ExtractLabel2".show()

func _on_body_exited(body: Node2D) -> void:
	player = null
	extract_timer.stop()
	$"../HUD/ExtractLabel1".hide()
	$"../HUD/ExtractLabel2".hide()

func _on_timer_timeout() -> void:
	player.extract()
	extract_timer.stop()

func _process(delta: float) -> void:
	if player:
		player.update_extract_timer(extract_timer.time_left)
		$"../HUD/ExtractLabel2".text = str(snapped(extract_timer.time_left,0.01)) # Update HUD text to remaining time, rounded to 2 d.p.
