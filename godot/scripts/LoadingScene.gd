## LoadingScene.gd
## Splash/loading screen shown at startup.
## Equivalent to LoadingScene.swift in the original Cocos2d project.
extends Node2D

const LOADING_DURATION := 3.0

@onready var logo: Sprite2D = $Logo
@onready var spinner: AnimatedSprite2D = $Spinner


func _ready() -> void:
	_animate_logo()
	spinner.play("load")
	SoundManager.play_background(false)

	await get_tree().create_timer(LOADING_DURATION).timeout
	GameState.go_to("home")


func _animate_logo() -> void:
	logo.scale = Vector2(0.1, 0.1)
	logo.modulate.a = 0.0

	var tween := create_tween().set_parallel(true)
	tween.tween_property(logo, "scale", Vector2(1.0, 1.0), 0.8).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(logo, "modulate:a", 1.0, 0.4)
