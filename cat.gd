extends Node2D

func meow():
	scale = Vector2(1.2, 1.2)
	rotation = randf_range(-0.2, 0.2)
	await get_tree().create_timer(0.1).timeout
	scale = Vector2(1, 1)
	rotation = 0
