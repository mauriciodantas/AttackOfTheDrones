## EnemyProjectile.gd
## Projectile dropped by enemy drones. Falls with gravity and can be shot down.
## Equivalent to TiroInimigo.swift in the original Cocos2d project.
extends RigidBody2D

signal destroyed  # emitted when shot down by the player

const BOX_VARIANTS := 4
const GRAVITY_SCALE_VALUE := 1.0  # uses project gravity of 985 px/s²

@onready var sprite: Sprite2D = $Sprite

var _frozen: bool = false


func _ready() -> void:
	add_to_group("enemy_projectile")
	gravity_scale = GRAVITY_SCALE_VALUE


func launch(variant: int = 0) -> void:
	# Use the same box variant the drone was carrying; fallback to random
	var v := variant if variant >= 1 and variant <= BOX_VARIANTS else (randi() % BOX_VARIANTS) + 1
	sprite.texture = load("res://assets/images/box%d.png" % v)

	# Add a small random horizontal drift so boxes don't fall perfectly straight
	var drift := randf_range(-30.0, 30.0)
	linear_velocity = Vector2(drift, 0.0)


func freeze() -> void:
	_frozen = true
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	sleeping = true


func destroy() -> void:
	emit_signal("destroyed")
	queue_free()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_bullet"):
		area.destroy()
		destroy()


func _on_body_entered(body: Node) -> void:
	# Destroy on contact with ground (StaticBody2D) or any body in ground group
	if body is StaticBody2D or body.is_in_group("ground"):
		queue_free()


func _physics_process(_delta: float) -> void:
	if _frozen:
		return

	var viewport_size := get_viewport_rect().size

	# Off-screen fallback
	if position.y > viewport_size.y + 100.0:
		queue_free()
		return

	# Fallback: box has come to rest near or below the visual ground level
	if position.y > viewport_size.y * 0.78 and linear_velocity.length_squared() < 400.0:
		queue_free()
