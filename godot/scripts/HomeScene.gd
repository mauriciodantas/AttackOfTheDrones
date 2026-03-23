## HomeScene.gd
## Main menu scene with Play and Settings buttons.
## Equivalent to HomeScene.swift in the original Cocos2d project.
extends Node2D

@onready var drone_home: Sprite2D = $DroneHome
@onready var man_home: Sprite2D = $ManHome
@onready var cloud1: Sprite2D = $Cloud1
@onready var cloud2: Sprite2D = $Cloud2

const DRONE_FINAL_POS := Vector2(764, 230)
const DRONE_FINAL_SCALE := Vector2(1.0, 1.0)
const MAN_FINAL_POS := Vector2(139, 634)


func _ready() -> void:
	SoundManager.play_background(false)
	_animate_drone()
	_animate_man()
	_animate_clouds()


func _animate_drone() -> void:
	# Entrada: começa fora da tela à esquerda, pequeno e levemente rotacionado
	# Equivale ao estado inicial do iOS: position(-200, 728), scale(0.2), rotation(10)
	drone_home.position = Vector2(-200, 40)
	drone_home.scale = Vector2(0.2, 0.2)
	drone_home.rotation_degrees = 10.0

	var tween := create_tween()

	# Fase 1: voa até a posição final enquanto cresce — ações paralelas (iOS: arrActions1 + spawn)
	tween.set_parallel(true)
	tween.tween_property(drone_home, "position", DRONE_FINAL_POS, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(drone_home, "scale", DRONE_FINAL_SCALE, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.set_parallel(false)

	# Fase 2: wobble de rotação em sequência (iOS: arrActions2 com CCActionEaseBackOut)
	# Parte de 10° → -10° → 20° → 0° (usando RotateBy -20, +30, -20)
	tween.tween_property(drone_home, "rotation_degrees", -10.0, 0.8).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(drone_home, "rotation_degrees", 20.0, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(drone_home, "rotation_degrees", 0.0, 0.9).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _animate_man() -> void:
	# Entrada: começa fora da tela à esquerda com delay
	# Equivale ao iOS: position(-250, 0), delay 1.5s, moveTo(120, 0) em 0.7s com EaseBackOut
	man_home.position = Vector2(-250.0, MAN_FINAL_POS.y)

	var tween := create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(man_home, "position", MAN_FINAL_POS, 0.7).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


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
