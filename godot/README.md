# Attack of the Drones — Godot 4 Migration

This folder contains the full migration of **Attack of the Drones** from its
original Cocos2d / Swift (iOS) codebase to **Godot 4** (GDScript).

## Project Structure

```
godot/
├── project.godot          # Godot 4 project configuration
├── scenes/                # .tscn scene files
│   ├── LoadingScene.tscn
│   ├── HomeScene.tscn
│   ├── GameScene.tscn
│   ├── SettingsScene.tscn
│   ├── Drone.tscn         # Enemy drone node
│   ├── Person.tscn        # Civilian character node
│   ├── PlayerBullet.tscn  # Player projectile node
│   ├── EnemyProjectile.tscn
│   └── SoundManager.tscn
├── scripts/               # GDScript source files
│   ├── GameState.gd       # Singleton — scene transitions & global state
│   ├── SoundManager.gd    # Singleton — audio management
│   ├── LoadingScene.gd
│   ├── HomeScene.gd
│   ├── GameScene.gd       # Core gameplay logic
│   ├── SettingsScene.gd
│   ├── Drone.gd           # Enemy AI (was Aviao.swift)
│   ├── Person.gd          # Civilian (was Pessoa.swift)
│   ├── PlayerBullet.gd    # Player bullet (was TiroPlayer.swift)
│   └── EnemyProjectile.gd # Enemy projectile (was TiroInimigo.swift)
└── assets/
    ├── images/            # All PNG sprites from original project
    ├── audio/             # MP3/WAV audio from original project
    └── animations/        # Original .plist animation descriptors (reference)
```

## Migration Map

| Original (Cocos2d / Swift)       | Godot 4 (GDScript)              |
|----------------------------------|----------------------------------|
| `StateMachine.swift`             | `GameState.gd` (Autoload)        |
| `SoundPlayHelper.swift`          | `SoundManager.gd` (Autoload)     |
| `GameScene.swift`                | `GameScene.gd` + `GameScene.tscn`|
| `HomeScene.swift`                | `HomeScene.gd` + `HomeScene.tscn`|
| `LoadingScene.swift`             | `LoadingScene.gd` + `.tscn`      |
| `SettingsScene.swift`            | `SettingsScene.gd` + `.tscn`     |
| `Aviao.swift` (drone)            | `Drone.gd` + `Drone.tscn`        |
| `Pessoa.swift` (civilian)        | `Person.gd` + `Person.tscn`      |
| `TiroPlayer.swift` (bullet)      | `PlayerBullet.gd` + `.tscn`      |
| `TiroInimigo.swift` (enemy proj) | `EnemyProjectile.gd` + `.tscn`   |
| Chipmunk physics                 | Godot built-in 2D physics        |
| ObjectAL audio                   | Godot `AudioStreamPlayer`        |
| Cocos2d CCAction animations      | Godot `Tween` / `AnimatedSprite2D`|

## Game Mechanics Preserved

- **Tap-to-shoot**: Player taps screen → weapon rotates, bullet fires toward target
- **Drone spawning**: Every 2 s (+ random), alternating left/right, random height
- **Person spawning**: Every 2 s (+ random), walks along ground (y ≈ 90 px from bottom)
- **Scoring**: Drone destroyed → +100 | Enemy projectile shot down → +50
- **Lives**: Start with 5; civilian killed by enemy projectile → −1 life
- **Game Over**: 0 lives → freeze all enemies, show overlay, tap to return home
- **Settings**: Toggle background music and sound effects independently
- **Physics gravity**: 985 px/s² (matches original Chipmunk config)
- **Bullet speed**: 700 px/s (matches original)

## How to Open

1. Install [Godot 4](https://godotengine.org/download) (4.3 or newer).
2. Open Godot → **Import** → select this `godot/` folder → open `project.godot`.
3. Press **F5** to run.

## Notes on Animation

The original project used Cocos2d `.plist` sprite sheet descriptors (stored in
`assets/animations/` for reference). In Godot 4 these need to be converted to
`SpriteFrames` resources. Each `AnimatedSprite2D` node in the drone, person and
loading scenes should have a `SpriteFrames` resource configured in the editor
with the corresponding frames extracted from the original images.

The Godot editor's **SpriteFrames** panel (select an `AnimatedSprite2D` →
Inspector → Frames → edit) makes this straightforward.
