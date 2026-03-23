## SoundManager.gd
## Singleton (autoload) for audio management.
## Equivalent to SoundPlayHelper.swift in the original Cocos2d project.
extends Node

@onready var _music_player: AudioStreamPlayer = $MusicPlayer
@onready var _sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var _explosion_player: AudioStreamPlayer = $ExplosionPlayer
@onready var _impact_player: AudioStreamPlayer = $ImpactPlayer
@onready var _scream_player: AudioStreamPlayer = $ScreamPlayer
@onready var _game_over_player: AudioStreamPlayer = $GameOverPlayer

var _music_game: AudioStream = preload("res://assets/audio/backgroundGameplay.mp3")
var _music_menu: AudioStream = preload("res://assets/audio/backgroundMenu.mp3")
var _sfx_laser: AudioStream = preload("res://assets/audio/shootingLaser.wav")
var _sfx_explosion: AudioStream = preload("res://assets/audio/explosion.wav")
var _sfx_impact: AudioStream = preload("res://assets/audio/impact.wav")
var _sfx_scream: AudioStream = preload("res://assets/audio/scream.wav")
var _sfx_game_over: AudioStream = preload("res://assets/audio/game_over.wav")


func _ready() -> void:
	_music_player.volume_db = -6.0
	_sfx_player.volume_db = 0.0
	_music_player.finished.connect(_on_music_finished)


func _on_music_finished() -> void:
	if GameState.can_play_bg_sound:
		_music_player.play()


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


func play_explosion() -> void:
	if GameState.can_play_effect:
		_explosion_player.stream = _sfx_explosion
		_explosion_player.play()


func play_impact() -> void:
	if GameState.can_play_effect:
		_impact_player.stream = _sfx_impact
		_impact_player.play()


func play_scream() -> void:
	if GameState.can_play_effect:
		_scream_player.stream = _sfx_scream
		_scream_player.play()


func play_game_over() -> void:
	stop_music()
	_game_over_player.stream = _sfx_game_over
	_game_over_player.play()


func stop_music() -> void:
	_music_player.stop()
