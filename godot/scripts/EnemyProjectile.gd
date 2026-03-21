## EnemyProjectile.gd
## Projectile dropped by enemy drones. Falls with gravity and can be shot down.
## Equivalent to TiroInimigo.swift in the original Cocos2d project.
extends RigidBody2D

signal destroyed  # emitted when shot down by the player

const GRAVITY_SCALE_VALUE := 1.0  # uses project gravity of 985 px/s²

# All possible cargo textures a drone can carry
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

@onready var sprite: Sprite2D = $Sprite

var _frozen: bool = false


func _ready() -> void:
	add_to_group("enemy_projectile")
	gravity_scale = GRAVITY_SCALE_VALUE


func launch(variant: int = -1, drone_velocity: Vector2 = Vector2.ZERO) -> void:
	# variant is a direct index into CARGO_TEXTURES; -1 means pick at random
	var idx := variant if variant >= 0 and variant < CARGO_TEXTURES.size() \
		else randi() % CARGO_TEXTURES.size()
	sprite.texture = load(CARGO_TEXTURES[idx])

	# Inherit the drone's current velocity so the box launches at the same angle
	linear_velocity = drone_velocity

	# Rotate the whole body to match the launch direction
	if drone_velocity.length_squared() > 1.0:
		rotation = drone_velocity.angle()

	# Gentle tumble as it falls under gravity
	angular_velocity = randf_range(-3.5, 3.5)


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
