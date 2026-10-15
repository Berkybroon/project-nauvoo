extends Area2D

@onready var extract_timer = $Timer

var player

func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player = body
	extract_timer.start()
	$"../HUD/ExtractLabel1".show()
	$"../HUD/ExtractLabel2".show()

func _on_body_exited(body: Node2D) -> void:
	if body != player:
		return
	player = null
	extract_timer.stop()
	$"../HUD/ExtractLabel1".hide()
	$"../HUD/ExtractLabel2".hide()

func _on_timer_timeout() -> void:
	extract_timer.stop()
	if player:
		player.extract()

func _process(delta: float) -> void:
	if player:
		$"../HUD/ExtractLabel2".text = str(snapped(extract_timer.time_left,0.01)) # Update HUD text to remaining time, rounded to 2 d.p.
