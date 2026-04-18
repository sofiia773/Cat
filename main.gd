extends Control

# отримуємо ноду картинки
@onready var cat_image = $CatImage

# масив картинок
var cat_textures = [
	preload("res://assets/cat1.jpg"),
	preload("res://assets/cat2.jpg"),
	preload("res://assets/cat3.jpg"),
	preload("res://assets/cat4.jpg")
]

# запускається при старті
func _ready():
	# підключаємо кнопки вручну (ГАРАНТОВАНО працює)
	$UpButton.pressed.connect(_on_UpButton_pressed)
	$DownButton.pressed.connect(_on_DownButton_pressed)
	$LeftButton.pressed.connect(_on_LeftButton_pressed)
	$RightButton.pressed.connect(_on_RightButton_pressed)

	# ховаємо картинку на старті
	cat_image.visible = false

	print("READY") # для перевірки

# функція показу кота
func show_cat(index):
	cat_image.texture = cat_textures[index]
	cat_image.visible = true

# кнопки
func _on_UpButton_pressed():
	print("UP")
	show_cat(0)

func _on_DownButton_pressed():
	print("DOWN")
	show_cat(1)

func _on_LeftButton_pressed():
	print("LEFT")
	show_cat(2)

func _on_RightButton_pressed():
	print("RIGHT")
	show_cat(3)
