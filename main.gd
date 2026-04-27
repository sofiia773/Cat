extends Control

@onready var player = $Synth
@onready var cat_image = $CatImage

var playback
var sample_rate = 44100
var phase = 0.0
var frequency = 440.0

# коти
var cat_textures = [
	preload("res://assets/cat1.jpg"),
	preload("res://assets/cat2.jpg"),
	preload("res://assets/cat3.jpg"),
	preload("res://assets/cat5.jpg")
]

func _ready():
	# 🔊 ЗАПУСК СИНТЕЗАТОРА
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate
	generator.buffer_length = 0.1

	player.stream = generator
	player.play()

	playback = player.get_stream_playback()

	# 🎮 кнопки
	$UpButton.pressed.connect(_on_UpButton_pressed)
	$DownButton.pressed.connect(_on_DownButton_pressed)
	$LeftButton.pressed.connect(_on_LeftButton_pressed)
	$RightButton.pressed.connect(_on_RightButton_pressed)

	cat_image.visible = false

	print("READY")

func _process(delta):
	if playback == null:
		return

	var frames = playback.get_frames_available()

	for i in range(frames):
		var sample = sin(phase * TAU)
		playback.push_frame(Vector2(sample, sample))

		phase += frequency / sample_rate
		if phase >= 1.0:
			phase -= 1.0

# 🐱 + 🎹 разом
func show_cat(index):
	cat_image.texture = cat_textures[index]
	cat_image.visible = true

# 🎛 кнопки
func _on_UpButton_pressed():
	print("UP")
	show_cat(0)
	frequency = 440.0

func _on_DownButton_pressed():
	print("DOWN")
	show_cat(1)
	frequency = 494.0

func _on_LeftButton_pressed():
	print("LEFT")
	show_cat(2)
	frequency = 523.0

func _on_RightButton_pressed():
	print("RIGHT")
	show_cat(3)
	frequency = 587.0
