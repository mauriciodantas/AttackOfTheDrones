## PlayerBullet.gd
## Projectile fired by the player toward tapped/clicked position.
## Equivalent to TiroPlayer.swift in the original Cocos2d project.
extends Area2D

@onready var sprite: Sprite2D = $Sprite

var _velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("player_bullet")


func launch(velocity: Vector2) -> void:
	_velocity = velocity
	rotation = velocity.angle() + PI / 2.0


func _physics_process(delta: float) -> void:
	position += _velocity * delta

	var viewport_size := get_viewport_rect().size
	if (position.x > viewport_size.x + 50.0 or position.x < -50.0
			or position.y > viewport_size.y + 50.0 or position.y < -50.0):
		queue_free()


func destroy() -> void:
	queue_free()
