extends Control

@onready var player = $Synth
@onready var cat_image = $CatImage
@onready var pitch_slider = $PitchSlider
@onready var background = $Background
@onready var stars_node = $Stars
@onready var nyan_cat = $NyanCat
@onready var meow = $MeowPlayer   # 🔊 нове

var playback
var sample_rate = 44100
var phase = 0.0
var frequency = 440.0
var pitch_scale = 1.0

# 🌈 фон
var hue = 0.0

# ⭐ зірки
var stars = []

# 🐱 nyan режим
var nyan_mode = false
var nyan_phase = 0.0

# 🐱 звичайні коти
var cat_textures = [
	preload("res://assets/cat1.jpg"),
	preload("res://assets/cat2.jpg"),
	preload("res://assets/cat3.jpg"),
	preload("res://assets/cat5.jpg")
]

func _ready():
	# 🔊 синтезатор
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
	$DangerButton.pressed.connect(_on_DangerButton_pressed)

	# 👉 ЦЕНТРАЛЬНА КНОПКА
	$CenterButton.pressed.connect(_on_CenterButton_pressed)

	# 🎚 slider
	pitch_slider.value_changed.connect(_on_PitchSlider_value_changed)

	cat_image.visible = false
	nyan_cat.visible = false

	# ⭐ зірки
	for i in range(40):
		create_star()

	print("READY")

func _process(delta):
	# 🔊 м’який звук
	if playback != null:
		var frames = playback.get_frames_available()

		for i in range(frames):
			var sample = sin(phase * TAU) * 0.2
			playback.push_frame(Vector2(sample, sample))

			phase += (frequency * pitch_scale) / sample_rate
			if phase >= 1.0:
				phase -= 1.0

	# 🌈 фон
	hue += delta * 0.2
	if hue > 1.0:
		hue = 0.0

	background.color = Color.from_hsv(hue, 0.6, 1.0)

	# ⭐ пульсація зірок
	for star_data in stars:
		var star = star_data["node"]

		star_data["phase"] += delta * 3.0
		var scale = 1.0 + sin(star_data["phase"]) * 0.3

		var base = star_data["base_size"]
		star.size = Vector2(base * scale, base * scale)

	# 🐱 nyan пульсація
	if nyan_mode:
		nyan_phase += delta * 1.5
		var scale = 1.0 + sin(nyan_phase) * 0.05
		nyan_cat.scale = Vector2(scale, scale)

# ⭐ створення зірки
func create_star():
	var star = ColorRect.new()
	star.color = Color(1, 1, 1)

	var size = randf_range(2, 5)
	star.size = Vector2(size, size)

	star.position = Vector2(
		randf_range(0, get_viewport_rect().size.x),
		randf_range(0, get_viewport_rect().size.y)
	)

	stars_node.add_child(star)

	stars.append({
		"node": star,
		"base_size": size,
		"phase": randf() * TAU
	})

# 🐱 показ кота
func show_cat(index):
	if nyan_mode:
		return

	cat_image.texture = cat_textures[index]
	cat_image.visible = true

# 🎛 кнопки
func _on_UpButton_pressed():
	show_cat(0)
	frequency = 440.0

func _on_DownButton_pressed():
	show_cat(1)
	frequency = 494.0

func _on_LeftButton_pressed():
	show_cat(2)
	frequency = 523.0

func _on_RightButton_pressed():
	show_cat(3)
	frequency = 587.0

# 🎚 slider
func _on_PitchSlider_value_changed(value):
	pitch_scale = value

# 🔊 CENTER BUTTON → МЯУ
func _on_CenterButton_pressed():
	print("MEOW 🐱")
	meow.play()

# 🔴 NYAN MODE
func _on_DangerButton_pressed():
	print("NYAN MODE")

	nyan_mode = true

	cat_image.visible = false
	nyan_cat.visible = true

	nyan_cat.size = Vector2(300, 300)

	var screen = get_viewport_rect().size
	nyan_cat.position = screen / 2 - nyan_cat.size / 2

	nyan_cat.z_index = 100

	frequency = 600
	pitch_scale = 1.5
