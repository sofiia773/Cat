extends Control

@onready var player = $Synth
@onready var cat_image = $CatImage
@onready var pitch_slider = $PitchSlider

var playback
var sample_rate = 44100
var phase = 0.0
var frequency = 440.0
var pitch_scale = 1.0

# 🐱 коти
var cat_textures = [
	preload("res://assets/cat1.jpg"),
	preload("res://assets/cat2.jpg"),
	preload("res://assets/cat3.jpg"),
	preload("res://assets/cat5.jpg")
]

func _ready():
	# 🔊 СИНТЕЗАТОР
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

	# 🎚 slider (ГАРАНТОВАНО підключений)
	pitch_slider.value_changed.connect(_on_PitchSlider_value_changed)

	# 🐱 ховаємо кота
	cat_image.visible = false

	print("READY")

func _process(delta):
	if playback == null:
		return

	var frames = playback.get_frames_available()

	for i in range(frames):
		# 🔥 крутіший звук (square wave)
		var sample = sign(sin(phase * TAU))

		playback.push_frame(Vector2(sample, sample))

		# 🎚 враховуємо slider
		phase += (frequency * pitch_scale) / sample_rate
		if phase >= 1.0:
			phase -= 1.0

# 🐱 показ кота
func show_cat(index):
	cat_image.texture = cat_textures[index]
	cat_image.visible = true

# 🎛 кнопки (звук + коти)
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

# 🎚 slider
func _on_PitchSlider_value_changed(value):
	print("PITCH:", value)
	pitch_scale = value
