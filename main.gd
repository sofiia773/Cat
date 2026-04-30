extends Control  # головна сцена (UI)

# посилання на ноди в сцені
@onready var player = $Synth              # синтезатор (генерує звук)
@onready var cat_image = $CatImage        # звичайний котик
@onready var pitch_slider = $PitchSlider  # слайдер висоти звуку
@onready var background = $Background     # фон
@onready var stars_node = $Stars          # контейнер для зірок
@onready var nyan_cat = $NyanCat          # nyan котик
@onready var meow = $MeowPlayer           # звук "мяу"
@onready var nyan_music = $NyanMusic      # музика nyan cat

# змінні для синтезатора
var playback               # буфер аудіо
var sample_rate = 44100    # частота дискретизації
var phase = 0.0            # фаза хвилі
var frequency = 440.0      # частота (нота)
var pitch_scale = 1.0      # множник для висоти звуку

# чи увімкнений синт
var synth_enabled = true

# фон
var hue = 0.0  # значення кольору (HSV)

# список зірок
var stars = []

# режим nyan
var nyan_mode = false
var nyan_phase = 0.0  # для анімацій

# масив картинок котів
var cat_textures = [
	preload("res://assets/cat1.jpg"),
	preload("res://assets/cat2.jpg"),
	preload("res://assets/cat3.jpg"),
	preload("res://assets/cat5.jpg")
]

func _ready():
	# створюємо аудіо генератор
	var generator = AudioStreamGenerator.new()
	generator.mix_rate = sample_rate      # задаємо частоту
	generator.buffer_length = 0.1         # довжина буфера

	player.stream = generator             # прив’язуємо до плеєра
	player.play()                         # запускаємо
	playback = player.get_stream_playback()  # отримуємо доступ до буфера

	# підключення кнопок
	$UpButton.pressed.connect(_on_UpButton_pressed)
	$DownButton.pressed.connect(_on_DownButton_pressed)
	$LeftButton.pressed.connect(_on_LeftButton_pressed)
	$RightButton.pressed.connect(_on_RightButton_pressed)
	$DangerButton.pressed.connect(_on_DangerButton_pressed)
	$CenterButton.pressed.connect(_on_CenterButton_pressed)

	# підключення слайдера
	pitch_slider.value_changed.connect(_on_PitchSlider_value_changed)

	# ховаємо картинки при старті
	cat_image.visible = false
	nyan_cat.visible = false

	# створюємо 40 зірок
	for i in range(40):
		create_star()

	print("READY")  # перевірка

func _process(delta):
	# генерація звуку (тільки якщо синт увімкнений)
	if playback != null and synth_enabled:
		var frames = playback.get_frames_available()

		for i in range(frames):
			# синус хвиля = м’який звук
			var sample = sin(phase * TAU) * 0.2
			playback.push_frame(Vector2(sample, sample))

			# рух фази
			phase += (frequency * pitch_scale) / sample_rate
			if phase >= 1.0:
				phase -= 1.0

	# звичайний фон (якщо не nyan mode)
	if not nyan_mode:
		hue += delta * 0.2
		if hue > 1.0:
			hue = 0.0
		background.color = Color.from_hsv(hue, 0.6, 1.0)

	# анімація зірок
	for star_data in stars:
		var star = star_data["node"]

		star_data["phase"] += delta * 3.0
		var scale = 1.0 + sin(star_data["phase"]) * 0.3
		var base = star_data["base_size"]

		star.size = Vector2(base * scale, base * scale)

	# NYAN ENERGY MODE
	if nyan_mode:
		nyan_phase += delta * 10.0  # швидкість

		# пульсація кота
		var scale = 1.0 + sin(nyan_phase) * 0.15
		nyan_cat.scale = Vector2(scale, scale)

		# зміна кольору
		var disco_hue = fmod(nyan_phase * 2.0, 1.0)
		nyan_cat.modulate = Color.from_hsv(disco_hue, 1.0, 1.0)

		# обертання
		nyan_cat.rotation += 6.0 * delta

		# фон швидкий
		hue += delta * 3.0
		background.color = Color.from_hsv(hue, 1.0, 1.0)

		# зірки хаотичні
		for star_data in stars:
			var star = star_data["node"]

			star_data["phase"] += delta * 12.0
			var star_scale = 1.0 + sin(star_data["phase"]) * 1.2
			var base = star_data["base_size"]

			star.size = Vector2(base * star_scale, base * star_scale)

# створення однієї зірки
func create_star():
	var star = ColorRect.new()  # квадрат
	star.color = Color(1, 1, 1) # білий

	var size = randf_range(2, 5)
	star.size = Vector2(size, size)

	# випадкова позиція
	star.position = Vector2(
		randf_range(0, get_viewport_rect().size.x),
		randf_range(0, get_viewport_rect().size.y)
	)

	stars_node.add_child(star)

	# зберігаємо дані
	stars.append({
		"node": star,
		"base_size": size,
		"phase": randf() * TAU
	})

# показ кота
func show_cat(index):
	if nyan_mode:
		return  # не показуємо в nyan режимі

	cat_image.texture = cat_textures[index]
	cat_image.visible = true

# кнопки
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

# мяу
func _on_CenterButton_pressed():
	meow.play()

# slider
func _on_PitchSlider_value_changed(value):
	pitch_scale = value

# NYAN MODE
func _on_DangerButton_pressed():
	print("NYAN ENERGY MODE")

	nyan_mode = true

	cat_image.visible = false
	nyan_cat.visible = true

	# розмір
	nyan_cat.size = Vector2(300, 300)

	# центр обертання
	nyan_cat.pivot_offset = nyan_cat.size / 2

	# центр екрану
	var screen = get_viewport_rect().size
	nyan_cat.position = screen / 2 - nyan_cat.size / 2

	nyan_cat.z_index = 100  # поверх всього

	# вимикаємо синт
	synth_enabled = false
	player.stop()

	# запускаємо музику
	nyan_music.play()
