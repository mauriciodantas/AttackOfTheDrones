## Person.gd
## Civilian character that walks across the bottom of the screen.
## Equivalent to Pessoa.swift in the original Cocos2d project.
extends CharacterBody2D

signal killed  # emitted when hit by an enemy projectile

@onready var sprite: AnimatedSprite2D = $Sprite

var _velocity: Vector2 = Vector2.ZERO
var _frozen: bool = false

const NUM_VARIANTS := 4


func _ready() -> void:
	var variant := (randi() % NUM_VARIANTS) + 1
	sprite.animation = "guy%d" % variant
	sprite.play()


func launch(velocity: Vector2) -> void:
	_velocity = velocity


func _physics_process(delta: float) -> void:
	if _frozen:
		return

	position += _velocity * delta

	var viewport_size := get_viewport_rect().size
	if position.x > viewport_size.x + 50.0 or position.x < -50.0:
		queue_free()


func freeze() -> void:
	_frozen = true
	sprite.stop()


# Called by Area2D overlap with enemy projectile
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy_projectile"):
		area.destroy()
		emit_signal("killed")
		queue_free()
