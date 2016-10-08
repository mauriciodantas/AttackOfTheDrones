//
//  HomeScene.swift
//  CocosSwift
//
//  Created by Thales Toniolo on 10/09/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation

// MARK: - Class Definition
class HomeScene : CCScene {
    // MARK: - Public Objects
    
    // MARK: - Private Objects
    private let screenSize:CGSize = CCDirector.sharedDirector().viewSize()
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        //  background
        let background:CCSprite = CCSprite(imageNamed: "bgHome.png")
        background.position = CGPointMake(self.screenSize.width/2, self.screenSize.height/2)
        background.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(background, z:0)
        
        // Drone
        let drone:CCSprite = CCSprite(imageNamed: "droneHome.png")
        drone.position = CGPointMake(-200, 728)
        drone.anchorPoint = CGPointMake(0.5, 0.8)
        drone.scale = 0.2
        drone.rotation = 10
        self.addChild(drone, z:2)
        
        // Logo
        let logo:CCSprite = CCSprite(imageNamed: "logo.png")
        logo.position = CGPointMake(self.screenSize.width/2, self.screenSize.height/2)
        logo.anchorPoint = CGPointMake(0.5, 0.5)
        self.addChild(logo, z:1)
        
        // Man
        let man:CCSprite = CCSprite(imageNamed: "manHome.png")
        man.position = CGPointMake(-250.0, 0.0)
        man.anchorPoint = CGPointMake(0.0, 0.0)
        self.addChild(man, z:2)
        
        //Botao Jogar
        let btJogar:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("btPlay.png").spriteFrame)
        btJogar.position = CGPointMake(self.screenSize.width/2 + 200, self.screenSize.height/2 - 280)
        btJogar.anchorPoint = CGPointMake(0.5, 0.5)
        btJogar.zoomWhenHighlighted = true
        btJogar.block = {_ in StateMachine.sharedInstance.changeScene(StateMachineScenes.GameScene, isFade:true)}
        self.addChild(btJogar, z:2)
        
        //Botao Settings
        let settings:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("settings.png").spriteFrame)
        settings.position = CGPointMake(self.screenSize.width - 20, self.screenSize.height - 20)
        settings.anchorPoint = CGPointMake(1.0, 1.0)
        settings.scale = 0.5
        settings.zoomWhenHighlighted = false
        settings.block = {_ in StateMachine.sharedInstance.changeScene(StateMachineScenes.SettingsScene, isFade:true)}
        self.addChild(settings, z:2)
        
        let velDrone:Double = 2.0
        
        let arrActions1:[CCAction] = [
            CCActionEase.actionWithAction(CCActionMoveTo.actionWithDuration(velDrone, position:  CGPointMake(655, 660) ) as! CCActionInterval) as! CCAction,
            CCActionScaleTo.actionWithDuration(velDrone, scale: 0.9) as! CCAction
        ]
        
        let arrActions2:[CCAction] = [
            CCActionEaseBackOut.actionWithAction(CCActionRotateBy.actionWithDuration(0.8, angle: -20) as! CCActionInterval) as! CCAction,
            CCActionEaseBackOut.actionWithAction(CCActionRotateBy.actionWithDuration(0.9, angle: 30) as! CCActionInterval) as! CCAction,
            CCActionEaseBackOut.actionWithAction(CCActionRotateBy.actionWithDuration(0.9, angle: -20) as! CCActionInterval) as! CCAction
        ]
        
        let arrActions3:[CCAction] = [
            CCActionDelay.actionWithDuration(1.5) as! CCAction,
            CCActionEase.actionWithAction(CCActionMoveTo.actionWithDuration(0.7, position:  CGPointMake(120.0, 0.0) ) as! CCActionInterval) as! CCAction
        ]
        
        let spawn: CCActionFiniteTime = CCActionSpawn.actionWithArray(arrActions1) as! CCActionFiniteTime
        let sequence: CCActionFiniteTime = CCActionSequence.actionWithArray(arrActions2) as! CCActionFiniteTime
        let sequence2:CCAction = CCActionSequence.actionWithArray(arrActions3) as! CCAction
        
        //drone.runAction(CCActionSequence.actionOne(spawn, two: sequence) as! CCAction)
        drone.runAction(CCActionSequence.actionWithArray([spawn, sequence]) as! CCAction)
        man.runAction(sequence2)
    }
    
    override func onEnter() {
        // Chamado apos o init quando entra no director
        super.onEnter()
    }
    
    override func onExit() {
        // Chamado quando sai do director
        super.onExit()
    }
}
