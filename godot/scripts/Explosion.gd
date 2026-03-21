## Explosion.gd
## Small one-shot explosion effect spawned when a drone is destroyed.
extends Node2D

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	# Burst: scale up quickly then fade out
	var tween := create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(2.5, 2.5), 0.35) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.35) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)
