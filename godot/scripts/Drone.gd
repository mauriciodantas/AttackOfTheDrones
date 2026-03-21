## Drone.gd
## Enemy drone that crosses the screen and fires projectiles.
## Equivalent to Aviao.swift in the original Cocos2d project.
extends CharacterBody2D

signal hit  # emitted when destroyed by a player bullet

const EnemyProjectileScene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")
const ExplosionScene: PackedScene = preload("res://scenes/Explosion.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var box_sprite: Sprite2D = $Box

var _h_speed: float = 0.0       # horizontal speed (signed)
var _start_y: float = 0.0       # y at launch, centre of the sine wave
var _wave_amp: float = 0.0      # vertical oscillation amplitude (px)
var _wave_freq: float = 0.0     # oscillation frequency (Hz)
var _phase: float = 0.0         # random start phase so drones don't sync up
var _time: float = 0.0
var _shoot_interval: float = 4.0
var _frozen: bool = false
var _box_variant: int = 1


func _ready() -> void:
	# Pick one of two drone animation variants at random
	var variant := (randi() % 2) + 1
	sprite.animation = "drone%d" % variant
	sprite.play()

	# Pick a random box texture to carry
	_box_variant = (randi() % 4) + 1
	box_sprite.texture = load("res://assets/images/box%d.png" % _box_variant)


func launch(velocity: Vector2, shoot_interval: float) -> void:
	_h_speed      = velocity.x
	_start_y      = position.y
	_wave_amp     = randf_range(35.0, 130.0)   # vertical swing range
	_wave_freq    = randf_range(0.35, 1.4)      # oscillations per second
	_phase        = randf_range(0.0, TAU)       # randomise starting point
	_shoot_interval = shoot_interval
	_schedule_shoot()


func get_width() -> float:
	return collision_shape.shape.size.x if collision_shape.shape is RectangleShape2D else 64.0


func _physics_process(delta: float) -> void:
	if _frozen:
		return

	_time += delta

	# Horizontal movement + sinusoidal vertical oscillation
	position.x += _h_speed * delta
	position.y = _start_y + sin(_time * _wave_freq * TAU + _phase) * _wave_amp

	# Keep drone within the flight band (15 %–75 % of screen height)
	var viewport_size := get_viewport_rect().size
	position.y = clamp(position.y, viewport_size.y * 0.15, viewport_size.y * 0.75)

	# Tilt the sprite to match the instantaneous flight angle
	var dy_dt: float = cos(_time * _wave_freq * TAU + _phase) * _wave_amp * _wave_freq * TAU
	var tilt: float = atan2(dy_dt, abs(_h_speed))
	tilt = clamp(tilt, -deg_to_rad(30.0), deg_to_rad(30.0))
	# Flip sign for left-moving drones (scale.x = -1) so the nose points correctly
	var final_tilt: float = tilt if _h_speed >= 0.0 else -tilt
	sprite.rotation    = final_tilt
	box_sprite.rotation = final_tilt

	# Remove self once off-screen horizontally
	if position.x > viewport_size.x + 100.0 or position.x < -100.0:
		queue_free()


func _schedule_shoot() -> void:
	var delay := _shoot_interval + randf_range(0.0, 3.0)
	await get_tree().create_timer(delay).timeout
	if is_inside_tree() and not _frozen:
		_shoot()
		_schedule_shoot()


func _shoot() -> void:
	box_sprite.visible = false

	# Compute the drone's instantaneous vertical speed so the box inherits it
	var dy_dt: float = cos(_time * _wave_freq * TAU + _phase) * _wave_amp * _wave_freq * TAU

	var projectile := EnemyProjectileScene.instantiate() as Node2D
	get_parent().add_child(projectile)
	projectile.global_position = box_sprite.global_position
	projectile.launch(_box_variant, Vector2(_h_speed, dy_dt))
	projectile.destroyed.connect(_on_projectile_destroyed)


func _on_projectile_destroyed() -> void:
	# Notify the GameScene to add score for destroying enemy projectile
	var game_scene := _find_game_scene()
	if game_scene and game_scene.has_method("on_enemy_projectile_destroyed"):
		game_scene.on_enemy_projectile_destroyed()


func _find_game_scene() -> Node:
	var node := get_parent()
	while node:
		if node.has_method("on_enemy_projectile_destroyed"):
			return node
		node = node.get_parent()
	return null


func freeze() -> void:
	_frozen = true
	sprite.stop()


# Called by Area2D overlap with player bullet
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		area.destroy()
		_spawn_explosion()
		emit_signal("hit")
		queue_free()


func _spawn_explosion() -> void:
	SoundManager.play_explosion()
	var explosion := ExplosionScene.instantiate() as Node2D
	get_parent().add_child(explosion)
	explosion.global_position = global_position
