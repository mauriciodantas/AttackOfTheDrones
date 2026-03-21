## HomeScene.gd
## Main menu scene with Play and Settings buttons.
## Equivalent to HomeScene.swift in the original Cocos2d project.
extends Node2D

@onready var drone_home: Sprite2D = $DroneHome
@onready var cloud1: Sprite2D = $Cloud1
@onready var cloud2: Sprite2D = $Cloud2


func _ready() -> void:
	SoundManager.play_background(false)
	_animate_drone()
	_animate_clouds()


func _animate_drone() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(drone_home, "position:y", drone_home.position.y - 20.0, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(drone_home, "position:y", drone_home.position.y, 1.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _animate_clouds() -> void:
	var screen_width := get_viewport_rect().size.x

	for cloud in [cloud1, cloud2]:
		var tween := create_tween().set_loops()
		var duration := randf_range(12.0, 20.0)
		tween.tween_property(cloud, "position:x", screen_width + 100.0, duration)
		tween.tween_callback(func(): cloud.position.x = -100.0)


func _on_play_button_pressed() -> void:
	GameState.go_to("game")


func _on_settings_button_pressed() -> void:
	GameState.go_to("settings")
