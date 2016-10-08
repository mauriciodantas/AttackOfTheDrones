//
//  SoundPlayHelper.m
//  CocosSwift
//
//  Created by Thales Toniolo on 10/09/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation

enum GameMusicAndSoundFx:String {
    case MusicInGame = "backgroundGameplay.mp3"
    case MusicInHome = "backgroundMenu.mp3"
    case ShootingTap = "shootingLaser.wav"
    //case Damage = "damage.mp3"
    //case EnemyDestroy = "enemyDestroy.mp3"
    //case SoundFXButtonTap = "SoundFXButtonTap.mp3"
    
    static let allSoundFx = [MusicInGame, MusicInHome, ShootingTap]
}

class SoundPlayHelper {
    
    
    var canPlayEffect:Bool = true
    var canPlayBGSound:Bool = true
    
       class var sharedInstance:SoundPlayHelper {
        struct Static {
            static var instance: SoundPlayHelper?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = SoundPlayHelper()
        }
        
        return Static.instance!
    }
    
    // MARK: Private Methods
    
    // MARK: Public Methods
    func preloadSoundsAndMusic() {
        // Habilita o cache de audio
        OALSimpleAudio.sharedInstance().preloadCacheEnabled = true
        
        // Apenas uma musica de fundo pode ser cacheada
        OALSimpleAudio.sharedInstance().preloadBg(GameMusicAndSoundFx.MusicInHome.rawValue)
        
        // Itera todos os SoundsFX para cachear
        for music in GameMusicAndSoundFx.allSoundFx {
            OALSimpleAudio.sharedInstance().preloadEffect(music.rawValue)
        }
        
        // Define o volume default
        setMusicDefaultVolume()
    }
    
    func playSoundWithControl(aGameMusic:GameMusicAndSoundFx) {
        
        if(self.canPlayEffect){
            OALSimpleAudio.sharedInstance().playEffect(aGameMusic.rawValue)
        }
    }
    
    func playMusicWithControl(aGameMusic:GameMusicAndSoundFx, withLoop:Bool) {
        if(self.canPlayBGSound){
            OALSimpleAudio.sharedInstance().stopBg()
            OALSimpleAudio.sharedInstance().preloadBg(aGameMusic.rawValue)
            OALSimpleAudio.sharedInstance().playBgWithLoop(withLoop)
        }
    }
    
    func stopAllSounds() {
        OALSimpleAudio.sharedInstance().stopEverything()
    }
    
    func setMusicVolume(aVolume:Float) {
        OALSimpleAudio.sharedInstance().bgVolume = aVolume
    }
    
    func setMusicPauseVolume() {
        OALSimpleAudio.sharedInstance().bgVolume = 0.25
    }
    
    func setMusicDefaultVolume() {
        OALSimpleAudio.sharedInstance().bgVolume = 0.6
        OALSimpleAudio.sharedInstance().effectsVolume = 1.0
    }
    
    
}
