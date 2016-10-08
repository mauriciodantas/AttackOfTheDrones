//
//  LoadingScene.swift
//  CocosSwift
//
//  Created by Thales Toniolo on 10/09/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation

// MARK: - Class Definition
class LoadingScene : CCScene {
    // MARK: - Public Objects
    
    // MARK: - Private Objects
    private let screenSize:CGSize = CCDirector.sharedDirector().viewSize()
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        // Preload do plist
        CCSpriteFrameCache.sharedSpriteFrameCache().addSpriteFramesWithFile("load.plist")
        
        // Background
        let imgBackground:CCSprite = CCSprite(imageNamed: "bgSplashScreen.png")
        imgBackground.anchorPoint = CGPointMake(0.0, 0.0)
        imgBackground.position = CGPointMake(0.0, 0.0)
        self.addChild(imgBackground, z:0)
        
        // Loader
        let spriteLoading:CCSprite?
        spriteLoading = self.gerarAnimacaoSpriteWithName("load", aQtdFrames: 6)
        spriteLoading!.anchorPoint = CGPointMake(0.5, 0.5);
        spriteLoading!.position = CGPointMake(screenSize.width/2, self.screenSize.height - 130)
        spriteLoading?.scale = 0.5
        self.addChild(spriteLoading, z:1)
        
        // Logo
        let logo:CCSprite = CCSprite(imageNamed: "logo.png")
        logo.anchorPoint = CGPointMake(0.5, 0.5)
        logo.position = CGPointMake(-500.0, (self.screenSize.height/2) + 300 )
        self.addChild(logo, z:1)
        
        let arrActions:[CCAction] = [
            CCActionEaseElasticInOut.actionWithAction(CCActionMoveTo.actionWithDuration(1.5, position:  CGPointMake(900, (self.screenSize.height/2) + 120) ) as! CCActionInterval, period: 3.5) as! CCAction,
            CCActionEaseBackOut.actionWithAction(CCActionMoveTo.actionWithDuration(0.4, position:  CGPointMake(screenSize.width/2, self.screenSize.height/2) ) as! CCActionInterval) as! CCAction
        ]
        
        let sequence:CCAction = CCActionSequence.actionWithArray(arrActions) as! CCAction
        logo.runAction(sequence)
        
        // Logo Cocos
        let cocos:CCSprite = CCSprite(imageNamed: "logoCocos.png")
        cocos.anchorPoint = CGPointMake(0.5, 0.5)
        cocos.position = CGPointMake(self.screenSize.width/2, 100.0)
        cocos.opacity = 0.0
        self.addChild(cocos, z:1)
        
        cocos.runAction(CCActionFadeIn.actionWithDuration(3) as! CCAction)
        
        DelayHelper.sharedInstance.callBlock({ _ in
            StateMachine.sharedInstance.changeScene(StateMachineScenes.HomeScene, isFade:true)
            }, withDelay: 3.0)
        
        
        SoundPlayHelper.sharedInstance.preloadSoundsAndMusic()
    }
    
    override func onEnter() {
        // Chamado apos o init quando entra no director
        super.onEnter()
    }
    
    // MARK: - Public Methods
    func gerarAnimacaoSpriteWithName(aSpriteName:String, aQtdFrames:Int) -> CCSprite {
        // Carrega os frames da animacao dentro do arquivo passado dada a quantidade de frames
        var animFrames:Array<CCSpriteFrame> = Array()
        for (var i = 1; i <= aQtdFrames; i++) {
            let name:String = "\(aSpriteName)\(i).png"
            animFrames.append(CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(name))
        }
        // Cria a animacao dos frames montados
        let animation:CCAnimation = CCAnimation(spriteFrames: animFrames, delay: 0.03)
        // Cria a acao com a animacao dos frames
        let animationAction:CCActionAnimate = CCActionAnimate(animation: animation)
        // Monta a repeticao eterna da animacao
        let actionForever:CCActionRepeatForever = CCActionRepeatForever(action: animationAction)
        // Monta o sprite com o primeiro quadro
        let spriteRet:CCSprite = CCSprite(imageNamed: "\(aSpriteName)\(1).png")
        // Executa a acao da animacao
        spriteRet.runAction(actionForever)
        
        // Retorna o sprite para controle na classe
        return spriteRet
    }
    
    // MARK: - Delegates/Datasources
    
    // MARK: - Death Cycle
    override func onExit() {
        // Chamado quando sai do director
        super.onExit()
    }
}
