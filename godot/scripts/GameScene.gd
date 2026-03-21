extends Node2D

# --- Difficulty parameters (mirror original Swift constants) ---
const BULLET_SPEED := 700.0
const MIN_DRONE_SPAWN_INTERVAL := 2.0
const MIN_PERSON_SPAWN_INTERVAL := 2.0
const MIN_DRONE_SHOOT_INTERVAL := 4.0
const MIN_DRONE_SPEED := 45.0   # pixels/second (original used pixels/frame * 60)
const MIN_PERSON_SPEED := 100.0

# --- Preloaded scenes ---
var DroneScene: PackedScene = preload("res://scenes/Drone.tscn")
var PersonScene: PackedScene = preload("res://scenes/Person.tscn")
var PlayerBulletScene: PackedScene = preload("res://scenes/PlayerBullet.tscn")
var HeartTexture: Texture2D = preload("res://assets/images/heart.png")

# --- UI nodes ---
@onready var score_label: Label = $UI/ScoreLabel
@onready var lives_container: HBoxContainer = $UI/LivesContainer
@onready var game_over_label: Label = $UI/GameOverLabel
@onready var fade_overlay: ColorRect = $UI/FadeOverlay
@onready var weapon: Sprite2D = $Weapon
@onready var world: Node2D = $World

# --- State ---
var _score: int = 0
var _lives: int = 5
const MAX_LIVES := 5
var _game_over: bool = false
var _game_over_ready: bool = false  # true only after game over animation finishes
var _spawn_left: bool = false  # alternates drone/person spawn side


func _ready() -> void:
	SoundManager.play_background(true)
	game_over_label.visible = false
	_setup_hearts()
	_update_ui()
	_schedule_drone_spawn()
	_schedule_person_spawn()


func _input(event: InputEvent) -> void:
	if _game_over:
		if _game_over_ready:
			var tapped: bool = (event is InputEventScreenTouch and event.pressed) \
				or (event is InputEventMouseButton and event.pressed \
					and event.button_index == MOUSE_BUTTON_LEFT)
			if tapped:
				GameState.go_to("home")
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_fire_bullet(event.position)
	elif event is InputEventScreenTouch and event.pressed:
		_fire_bullet(event.position)


# ---------------------------------------------------------------------------
# Weapon & Bullet
# ---------------------------------------------------------------------------

func _fire_bullet(target: Vector2) -> void:
	SoundManager.play_laser()

	var bullet := PlayerBulletScene.instantiate() as Node2D
	world.add_child(bullet)
	bullet.global_position = weapon.global_position

	var direction := (target - weapon.global_position).normalized()
	bullet.launch(direction * BULLET_SPEED)

	# Rotate weapon sprite to face target (pivot is at base, so rotation is clean)
	weapon.rotation = direction.angle() + PI / 2.0

	# Spawn bullet at barrel tip (top of weapon, 79px from pivot along direction)
	bullet.global_position = weapon.global_position + direction * 79.0


# ---------------------------------------------------------------------------
# Spawning
# ---------------------------------------------------------------------------

func _schedule_drone_spawn() -> void:
	var delay := MIN_DRONE_SPAWN_INTERVAL + randf_range(0.0, 2.0)
	await get_tree().create_timer(delay).timeout
	if not _game_over:
		_spawn_drone()
		_schedule_drone_spawn()


func _spawn_drone() -> void:
	var viewport_size := get_viewport_rect().size
	var drone := DroneScene.instantiate() as Node2D
	world.add_child(drone)

	_spawn_left = not _spawn_left
	var y := randf_range(viewport_size.y * 0.25, viewport_size.y * 0.65)
	var speed := MIN_DRONE_SPEED + randf_range(0.0, 45.0)

	if _spawn_left:
		drone.global_position = Vector2(-drone.get_width() / 2.0, y)
		drone.launch(Vector2(speed, 0.0), MIN_DRONE_SHOOT_INTERVAL)
	else:
		drone.global_position = Vector2(viewport_size.x + drone.get_width() / 2.0, y)
		drone.launch(Vector2(-speed, 0.0), MIN_DRONE_SHOOT_INTERVAL)
		drone.scale.x = -1.0

	drone.hit.connect(_on_drone_hit)


func _schedule_person_spawn() -> void:
	var delay := MIN_PERSON_SPAWN_INTERVAL + randf_range(0.0, 2.0)
	await get_tree().create_timer(delay).timeout
	if not _game_over:
		_spawn_person()
		_schedule_person_spawn()


func _spawn_person() -> void:
	var viewport_size := get_viewport_rect().size
	var person := PersonScene.instantiate() as Node2D
	world.add_child(person)

	var speed := MIN_PERSON_SPEED + randf_range(0.0, 70.0)

	# Alternate spawn side (independent of drone spawner)
	var from_left := randi() % 2 == 0
	if from_left:
		person.global_position = Vector2(-20.0, viewport_size.y * 0.88)
		person.launch(Vector2(speed, 0.0))
	else:
		person.global_position = Vector2(viewport_size.x + 20.0, viewport_size.y * 0.88)
		person.launch(Vector2(-speed, 0.0))
		person.scale.x = -1.0

	person.killed.connect(_on_person_killed)


# ---------------------------------------------------------------------------
# Collision callbacks (called from child nodes via signals)
# ---------------------------------------------------------------------------

func _on_drone_hit() -> void:
	_add_score(100)


func _on_person_killed() -> void:
	_lives -= 1
	_update_ui()
	if _lives <= 0:
		_trigger_game_over()


func on_enemy_projectile_destroyed() -> void:
	_add_score(50)


# ---------------------------------------------------------------------------
# Score & UI
# ---------------------------------------------------------------------------

func _add_score(amount: int) -> void:
	_score += amount
	_update_ui()


func _setup_hearts() -> void:
	for i in range(MAX_LIVES):
		var heart := TextureRect.new()
		heart.texture = HeartTexture
		heart.custom_minimum_size = Vector2(44, 44)
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		lives_container.add_child(heart)


func _update_hearts() -> void:
	for i in range(lives_container.get_child_count()):
		var heart := lives_container.get_child(i) as TextureRect
		if i < _lives:
			heart.modulate = Color(1.0, 1.0, 1.0, 1.0)   # coração ativo
		else:
			heart.modulate = Color(0.2, 0.2, 0.2, 0.35)  # coração perdido


func _update_ui() -> void:
	score_label.text = str(_score)
	_update_hearts()


# ---------------------------------------------------------------------------
# Game Over
# ---------------------------------------------------------------------------

func _trigger_game_over() -> void:
	_game_over = true

	# Freeze all enemies
	for child in world.get_children():
		if child.has_method("freeze"):
			child.freeze()

	SoundManager.play_game_over()

	# Phase 1: dark overlay fades in
	var t1 := create_tween()
	t1.tween_property(fade_overlay, "modulate:a", 0.78, 0.7) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await t1.finished

	# Phase 2: game over label pops in with scale + alpha
	game_over_label.visible = true
	game_over_label.modulate.a = 0.0
	game_over_label.scale = Vector2(0.25, 0.25)
	await get_tree().process_frame          # wait one frame so size is computed
	game_over_label.pivot_offset = game_over_label.size / 2.0

	var t2 := create_tween().set_parallel(true)
	t2.tween_property(game_over_label, "scale", Vector2(1.0, 1.0), 0.45) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	t2.tween_property(game_over_label, "modulate:a", 1.0, 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await t2.finished
	_game_over_ready = true


func _on_back_button_pressed() -> void:
	GameState.go_to("home")
