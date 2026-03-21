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
var _destroyed: bool = false
var _box_variant: int = 0  # index into EnemyProjectile.CARGO_TEXTURES

# Mirror of EnemyProjectile.CARGO_TEXTURES so the drone can show the same sprite
const CARGO_TEXTURES: Array[String] = [
	"res://assets/images/box1.png",
	"res://assets/images/box2.png",
	"res://assets/images/box3.png",
	"res://assets/images/box4.png",
	"res://assets/images/cargo_plant.png",
	"res://assets/images/cargo_pizza.png",
	"res://assets/images/cargo_bag.png",
	"res://assets/images/cargo_barrel.png",
	"res://assets/images/cargo_fruits.png",
	"res://assets/images/cargo_package.png",
]


func _ready() -> void:
	# Pick one of two drone animation variants at random
	var variant := (randi() % 2) + 1
	sprite.animation = "drone%d" % variant
	sprite.play()

	# Pick a random cargo from the full catalogue
	_box_variant = randi() % CARGO_TEXTURES.size()
	box_sprite.texture = load(CARGO_TEXTURES[_box_variant])


func launch(velocity: Vector2, shoot_interval: float) -> void:
	_h_speed      = velocity.x
	_start_y      = position.y
	_wave_amp     = randf_range(35.0, 130.0)   # vertical swing range
	_wave_freq    = randf_range(0.12, 0.45)     # oscillations per second
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
	sprite.rotation = final_tilt

	# Keep the box visually attached to the drone's undercarriage.
	# When the drone tilts, the attachment point (0, attach_y) rotates with it,
	# so we update the box position accordingly. The box itself stays upright
	# (gravity-aligned) so it looks like it's hanging from the drone.
	var attach_y: float = 38.0
	box_sprite.position = Vector2(-attach_y * sin(final_tilt), attach_y * cos(final_tilt))
	box_sprite.rotation = 0.0

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
	if _destroyed:
		return
	if area.is_in_group("player_bullet"):
		_destroyed = true
		_frozen = true
		area.destroy()
		_drop_box()
		_spawn_explosion()
		emit_signal("hit")
		queue_free()


func _drop_box() -> void:
	# If the box was already launched (shot), nothing to drop
	if not box_sprite.visible:
		return

	var dy_dt: float = cos(_time * _wave_freq * TAU + _phase) * _wave_amp * _wave_freq * TAU

	var projectile := EnemyProjectileScene.instantiate() as Node2D
	get_parent().add_child(projectile)
	projectile.global_position = box_sprite.global_position
	projectile.launch(_box_variant, Vector2(_h_speed, dy_dt))

	# Connect destroyed signal directly to the game scene, not to this drone
	# (the drone will be freed before the box can be shot down)
	var game_scene := _find_game_scene()
	if game_scene and game_scene.has_method("on_enemy_projectile_destroyed"):
		projectile.destroyed.connect(game_scene.on_enemy_projectile_destroyed)


func _spawn_explosion() -> void:
	SoundManager.play_explosion()
	var explosion := ExplosionScene.instantiate() as Node2D
	get_parent().add_child(explosion)
	explosion.global_position = global_position
