## SettingsScene.gd
## Settings/configuration scene for toggling audio.
## Equivalent to SettingsScene.swift in the original Cocos2d project.
extends Node2D

@onready var music_button: TextureButton = $UI/MusicButton
@onready var sound_button: TextureButton = $UI/SoundButton

var _tex_music_on: Texture2D = preload("res://assets/images/musicOn.png")
var _tex_music_off: Texture2D = preload("res://assets/images/musicOff.png")
var _tex_sound_on: Texture2D = preload("res://assets/images/soundOn.png")
var _tex_sound_off: Texture2D = preload("res://assets/images/soundOff.png")


func _ready() -> void:
	_update_buttons()


func _update_buttons() -> void:
	music_button.texture_normal = _tex_music_on if GameState.can_play_bg_sound else _tex_music_off
	sound_button.texture_normal = _tex_sound_on if GameState.can_play_effect else _tex_sound_off


func _on_music_button_pressed() -> void:
	GameState.can_play_bg_sound = not GameState.can_play_bg_sound
	if GameState.can_play_bg_sound:
		SoundManager.play_background(false)
	else:
		SoundManager.stop_music()
	_update_buttons()


func _on_sound_button_pressed() -> void:
	GameState.can_play_effect = not GameState.can_play_effect
	_update_buttons()


func _on_back_button_pressed() -> void:
	GameState.go_to("home")
