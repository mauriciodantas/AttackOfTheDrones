//
//  Settings.swift
//  CocosSwift
//
//  Created by Thales Toniolo on 10/09/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation

// MARK: - Class Definition
class SettingsScene: CCScene {
    // MARK: - Public Objects
    
    // MARK: - Private Objects
    private let screenSize:CGSize = CCDirector.sharedDirector().viewSize()
    
    var btSound:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("soundOn.png").spriteFrame)
    
    var btMusic:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("musicOn.png").spriteFrame)
    
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        // Background
        let imgBackground:CCSprite = CCSprite(imageNamed: "bgSplashScreen.png")
        imgBackground.anchorPoint = CGPointMake(0.0, 0.0)
        imgBackground.position = CGPointMake(0.0, 0.0)
        self.addChild(imgBackground, z:0)
        
        
        
        
        // Logo clound1
        let clound1:CCSprite = CCSprite(imageNamed: "cloud1.png")
        clound1.anchorPoint = CGPointMake(0.5, 0.5)
        clound1.position = CGPointMake(self.screenSize.width/2, self.screenSize.height/2)
        self.addChild(clound1, z:3)
        
        clound1.runAction(CCActionMoveBy.actionWithDuration(1.4, position:CGPointMake(200, 0)) as! CCAction)
        
        
        
        // Back button
        let backButton:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("back.png").spriteFrame)
        backButton.position = CGPointMake(self.screenSize.width - 10, self.screenSize.height - 10)
        backButton.anchorPoint = CGPointMake(1.0, 1.0)
        backButton.scale = 0.5
        backButton.zoomWhenHighlighted = true
        backButton.block = {_ in StateMachine.sharedInstance.changeScene(StateMachineScenes.HomeScene, isFade:true)}
        self.addChild(backButton, z:3)
        
        // Logo
        let logo:CCSprite = CCSprite(imageNamed: "logo.png")
        logo.position = CGPointMake(self.screenSize.width/2, self.screenSize.height - 300)
        logo.anchorPoint = CGPointMake(0.5, 0.5)
        logo.scale = 0.75
        self.addChild(logo, z:2)
        
        //Botao Som
        btSound.position = CGPointMake(self.screenSize.width/2 - 100, self.screenSize.height/2 - 150)
        btSound.anchorPoint = CGPointMake(0.5, 0.5)
        btSound.zoomWhenHighlighted = true
        btSound.block = {_ in
        
            SoundPlayHelper.sharedInstance.canPlayEffect = !SoundPlayHelper.sharedInstance.canPlayEffect
            
            if(SoundPlayHelper.sharedInstance.canPlayEffect){
            
            }
        
        
        }
        	
        self.addChild(btSound, z:3)
        
        //Botao Musica
        btMusic.position = CGPointMake(self.screenSize.width/2 + 100, self.screenSize.height/2 - 150)
        btMusic.anchorPoint = CGPointMake(0.5, 0.5)
        btMusic.zoomWhenHighlighted = true
        btMusic.block = {
            _ in
            
            SoundPlayHelper.sharedInstance.canPlayBGSound = !SoundPlayHelper.sharedInstance.canPlayBGSound
            
            if(SoundPlayHelper.sharedInstance.canPlayBGSound){
                SoundPlayHelper.sharedInstance.playMusicWithControl(GameMusicAndSoundFx.MusicInHome, withLoop: true)
            }
            else{
                SoundPlayHelper.sharedInstance.stopAllSounds()
            }
            

        
        }
        self.addChild(btMusic, z:3)
        
        
        // Integrantes
        let team:CCLabelTTF = CCLabelTTF(string: "Danilo Fernandes, Luis Silva, Mauricio Dantas, Michel Avelar e Renato Sanches\nCopyright Team Cactus", fontName: "Arial", fontSize: 20.0)
        team.color = CCColor.whiteColor()
        team.position = CGPointMake(self.screenSize.width/2, 40.0)
        team.anchorPoint = CGPointMake(0.5, 0)
        team.horizontalAlignment = CCTextAlignment.Center
        self.addChild(team, z:3)
        
       
       
    }
    
    override func onEnter() {
        // Chamado apos o init quando entra no director
        super.onEnter()
    }
    
    // Tick baseado no FPS
    override func update(delta: CCTime) {
        //...
    }

    
    // MARK: - Private Methods
    
    // MARK: - Public Methods
    
    // MARK: - Delegates/Datasources
    
    // MARK: - Death Cycle
    override func onExit() {
        // Chamado quando sai do director
        super.onExit()
    }
}
