extends "res://item_base.gd"

func on_use(player: Player):
	if player.health < 100:
		player.health += 25
		print("Used health pack! Player health:", player.health)
	else:
		print("Player's health is already full!")

func on_drop(player):
	print("Dropped the health pack.")
