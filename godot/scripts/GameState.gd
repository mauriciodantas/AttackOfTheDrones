## GameState.gd
## Singleton (autoload) that manages scene transitions and global game state.
## Equivalent to StateMachine.swift in the original Cocos2d project.
extends Node

const SCENES = {
	"loading": "res://scenes/LoadingScene.tscn",
	"home": "res://scenes/HomeScene.tscn",
	"game": "res://scenes/GameScene.tscn",
	"settings": "res://scenes/SettingsScene.tscn",
}

var can_play_effect: bool = true
var can_play_bg_sound: bool = true


func go_to(scene_name: String) -> void:
	if not SCENES.has(scene_name):
		push_error("GameState: unknown scene '%s'" % scene_name)
		return

	_update_music_for_scene(scene_name)

	var tree := get_tree()
	tree.change_scene_to_file(SCENES[scene_name])


func _update_music_for_scene(scene_name: String) -> void:
	var is_game_scene := scene_name == "game"
	SoundManager.play_background(is_game_scene)
