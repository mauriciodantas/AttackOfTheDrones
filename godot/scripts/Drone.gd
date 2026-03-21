## Drone.gd
## Enemy drone that crosses the screen and fires projectiles.
## Equivalent to Aviao.swift in the original Cocos2d project.
extends CharacterBody2D

signal hit  # emitted when destroyed by a player bullet

const EnemyProjectileScene: PackedScene = preload("res://scenes/EnemyProjectile.tscn")

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var box_sprite: Sprite2D = $Box

var _velocity: Vector2 = Vector2.ZERO
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
	_velocity = velocity
	_shoot_interval = shoot_interval
	_schedule_shoot()


func get_width() -> float:
	return collision_shape.shape.size.x if collision_shape.shape is RectangleShape2D else 64.0


func _physics_process(delta: float) -> void:
	if _frozen:
		return

	position += _velocity * delta

	# Remove self once off-screen
	var viewport_size := get_viewport_rect().size
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

	var projectile := EnemyProjectileScene.instantiate() as Node2D
	get_parent().add_child(projectile)
	projectile.global_position = box_sprite.global_position
	projectile.launch(_box_variant)
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
		emit_signal("hit")
		queue_free()
