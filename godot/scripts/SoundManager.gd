## SoundManager.gd
## Singleton (autoload) for audio management.
## Equivalent to SoundPlayHelper.swift in the original Cocos2d project.
extends Node

@onready var _music_player: AudioStreamPlayer = $MusicPlayer
@onready var _sfx_player: AudioStreamPlayer = $SFXPlayer

var _music_game: AudioStream = preload("res://assets/audio/backgroundGameplay.mp3")
var _music_menu: AudioStream = preload("res://assets/audio/backgroundMenu.mp3")
var _sfx_laser: AudioStream = preload("res://assets/audio/shootingLaser.wav")


func _ready() -> void:
	_music_player.volume_db = -6.0
	_sfx_player.volume_db = 0.0


func play_background(game_music: bool) -> void:
	if not GameState.can_play_bg_sound:
		_music_player.stop()
		return

	_music_player.stream = _music_game if game_music else _music_menu
	if not _music_player.playing:
		_music_player.play()


func play_laser() -> void:
	if GameState.can_play_effect:
		_sfx_player.stream = _sfx_laser
		_sfx_player.play()


func stop_music() -> void:
	_music_player.stop()
