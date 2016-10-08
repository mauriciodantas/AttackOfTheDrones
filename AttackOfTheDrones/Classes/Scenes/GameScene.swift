//
//  GameScene.swift
//  CocosSwift
//
//  Created by Thales Toniolo on 10/09/14.
//  Copyright (c) 2014 Flameworks. All rights reserved.
//
import Foundation

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
        return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

// MARK: - Class Definition
class GameScene: CCScene,CCPhysicsCollisionDelegate {
    // MARK: - Public Objects
    
    // MARK: - Private Objects
    private var scoreLabel:CCLabelTTF!
    private var life:CCLabelTTF!
    private var gameOverLabel:CCLabelTTF!
    private let screenSize:CGSize = CCDirector.sharedDirector().viewSize()
    private let player:CCSprite = CCSprite(imageNamed: "weapon.png")
    var velocidadeBala:CGFloat!
    var physicsWorld:CCPhysicsNode = CCPhysicsNode()
    var tempoMinimoProximoAviao:Double!
    var tempoMinimoProximoTiro:Double!
    var tempoMinimoProximaPessoa:Double!
    var velocidadeMinimaAviao:Double!
    var velocidadeMinimaPessoa:Double!
    var tempoQuedaTiroInimigo:CGFloat!
    private var score:Int!
    private var vidas:Int!
    private var tirosDados:Int!
    private var canPlay:Bool = true
    
    
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        self.physicsWorld.collisionDelegate = self
        self.physicsWorld.gravity = CGPointMake(0,-985)
        
        // Label life
        self.life = CCLabelTTF(string: "Life: 5", fontName: "Arial", fontSize: 26.0)
        self.life.color = CCColor.whiteColor()
        self.life.position = CGPointMake(10.0, self.screenSize.height - 10)
        self.life.anchorPoint = CGPointMake(0.0, 1.0)
        self.addChild(self.life, z:3)
        
        // Label score
        self.scoreLabel = CCLabelTTF(string: "Score", fontName: "Arial", fontSize: 26.0)
        self.scoreLabel.color = CCColor.whiteColor()
        self.scoreLabel.position = CGPointMake(self.screenSize.width/2, self.screenSize.height - 10)
        self.scoreLabel.anchorPoint = CGPointMake(0.5, 1.0)
        self.addChild(self.scoreLabel, z:3)
        
        //Game Over Label
        self.gameOverLabel = CCLabelTTF(string: "Game Over", fontName: "Arial", fontSize: 26.0)
        self.gameOverLabel.color = CCColor.whiteColor()
        self.gameOverLabel.position = CGPointMake(self.screenSize.width/2, self.screenSize.height/2)
        self.gameOverLabel.anchorPoint = CGPointMake(0.5, 1.0)
        self.gameOverLabel.visible = false
        self.addChild(self.gameOverLabel, z:3)

        
        // Back button
        let backButton:CCButton = CCButton(title: "", spriteFrame:CCSprite.spriteWithImageNamed("back.png").spriteFrame)
        backButton.position = CGPointMake(self.screenSize.width - 10, self.screenSize.height - 10)
        backButton.anchorPoint = CGPointMake(1.0, 1.0)
        backButton.scale = 0.5
        backButton.zoomWhenHighlighted = true
        backButton.block = {_ in StateMachine.sharedInstance.changeScene(StateMachineScenes.HomeScene, isFade:true)}
        self.addChild(backButton, z:3)

        
        let imgBackground:CCSprite = CCSprite(imageNamed: "bgGame.png")
        imgBackground.anchorPoint = CGPointMake(0.0, 0.0)
        imgBackground.position = CGPointMake(0.0, 0.0)
        self.addChild(imgBackground)
        
        let basePlayer:CCSprite = CCSprite(imageNamed: "baseWeapon.png")
        basePlayer.anchorPoint = CGPointMake(0.5, 0.5)
        basePlayer.position = CGPointMake(self.screenSize.width/2, 70)
        physicsWorld.addChild(basePlayer)
        
        self.player.anchorPoint = CGPointMake(0.5, 0.1)
        self.player.position = CGPointMake((self.screenSize.width/2), 110)
        self.physicsWorld.addChild(player,z:2)
        
        self.userInteractionEnabled = true
        
        self.addChild(self.physicsWorld)
        
        self.velocidadeBala = 700;
        
        self.tempoMinimoProximoAviao = 2
        
        self.tempoMinimoProximoTiro = 4
        
        self.tempoMinimoProximaPessoa = 2
        
        self.tempoQuedaTiroInimigo = 3
        
        self.velocidadeMinimaAviao = 7
        
        self.velocidadeMinimaPessoa = 10
        
        self.score  = 0
        
        self.vidas = 5
            
    }
    
    override func onEnter() {
        super.onEnter()
        DelayHelper.sharedInstance.callFunc("gerarAviao", onTarget: self, withDelay: 0.1)
        DelayHelper.sharedInstance.callFunc("gerarPessoa", onTarget: self, withDelay: 0.1)
    }
    
    // Tick baseado no FPS
    override func update(delta: CCTime) {
    }
    
    
    override func onExit() {
        super.onExit()
    }
    
    
    override func touchBegan(touch: UITouch!, withEvent event: UIEvent!) {
        if(self.canPlay){
            let locationInView:CGPoint = CCDirector.sharedDirector().convertTouchToGL(touch)
            addBulletAtPosition(locationInView)
        }
        else{
            StateMachine.sharedInstance.changeScene(StateMachineScenes.HomeScene, isFade:true)
        }
    }
    
    func addBulletAtPosition(position:CGPoint){
        let bullet =  TiroPlayer()
        
        bullet.position = CGPointMake(self.player.position.x, self.player.position.y)
        
        self.physicsWorld.addChild(bullet, z: 1)
        
        let posicaoFinalTiro = self.calcularPosicaoFinalTiro(player.position, pontoTiro: position)
        
        let distancia = self.calcularDistanciaEntrePontos(self.player.position, p2:posicaoFinalTiro)
                
        let tempo = self.calcularTempoTrajetoria(distancia)
        
        let angulo = self.calcularAngulo(bullet.position, p2: position)
        
        
        self.aplicarAngulo(angulo)
        
        self.contabilizaTiro()
        
        SoundPlayHelper.sharedInstance.playSoundWithControl(GameMusicAndSoundFx.ShootingTap)
        
        let actions: [CCAction] = [CCActionMoveTo.actionWithDuration(tempo, position: posicaoFinalTiro) as! CCAction,
            CCActionCallBlock.actionWithBlock({ () -> Void in
                bullet.removeFromParentAndCleanup(true)
            }) as! CCAction]
        bullet.runAction(CCActionSequence.actionWithArray(actions) as! CCAction)
        
    }
    
    func calcularDistanciaEntrePontos(p1: CGPoint, p2: CGPoint) -> CGFloat {
        let xDist:CGFloat = (p2.x - p1.x);
        let yDist:CGFloat = (p2.y - p1.y);
        let distance:CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
        return distance
    }
    
    func calcularTempoTrajetoria(distancia:CGFloat) -> Double {
        let tempo:CGFloat = distancia / self.velocidadeBala
        return Double.init(tempo)
    }
    
    func calcularAngulo(p1:CGPoint,p2:CGPoint ) -> Float {
        let deltaX = p1.x - p2.x;
        let deltaY = p1.y - p2.y;
        
        let angle = atan2f(Float(deltaY), Float(deltaX));
        return Float(270.0) - CC_RADIANS_TO_DEGREES(angle);
        
        
    }
    
    func gerarAviao(){
        
        if(self.canPlay){
        let esquerda = self.boolAleatorio()
        let aviao = Aviao(target: self, tempoEntreTiros: self.tempoMinimoProximoTiro, velocidadeMinimaPercurso: velocidadeMinimaAviao, esquerda:esquerda)
        aviao.anchorPoint = CGPointMake(0.5, 0.5)
        
        let altura = CGFloat(arc4random_uniform(100)+600)
        
        if(esquerda){
            aviao.position = CGPointMake(0, altura)
        }
        else{
            aviao.position = CGPointMake(1100, altura)
        }
        
        aviao.moveMe()
        self.physicsWorld.addChild(aviao,z:2)
        let tempoProximoAviao = Double(CGFloat(Float(arc4random()) / Float(UINT32_MAX)))+tempoMinimoProximoAviao
        DelayHelper.sharedInstance.callFunc("gerarAviao", onTarget: self, withDelay:tempoProximoAviao)
        }
    }
    
    
    func gerarPessoa(){
        
        if(self.canPlay){
        
        let esquerda:Bool = boolAleatorio()
        let pessoa = Pessoa(target: self, velocidadeMinimaPercurso: velocidadeMinimaPessoa, posicaoEsquerda: esquerda)
        pessoa.anchorPoint = CGPointMake(0.5, 0.5)
        
        if(esquerda){
            pessoa.position = CGPointMake(0, 90)
        }
        else{
            pessoa.position = CGPointMake(1300, 90)
            
        }
        pessoa.moveMe()
        self.physicsWorld.addChild(pessoa,z:2)
        let tempoProximaPessoa = Double(CGFloat(Float(arc4random()) / Float(UINT32_MAX)))+tempoMinimoProximaPessoa
        DelayHelper.sharedInstance.callFunc("gerarPessoa", onTarget: self, withDelay:tempoProximaPessoa)
        }
    }
    
    
    func calcularPosicaoFinalTiro(pontoJogador:CGPoint, pontoTiro:CGPoint) -> CGPoint{
        let offset = pontoTiro - pontoJogador
        let direction = offset.normalized()
        let shootAmount = direction * 1000
        let realDest = shootAmount + pontoTiro
        return realDest
    }
    
    func aplicarAngulo(angulo:Float){
    
        let arrActions: [CCAction] = [CCActionRotateTo.actionWithDuration(0.10, angle: angulo) as! CCAction,
                                       CCActionCallBlock.actionWithBlock({ () -> Void in
    
                              
                                    }) as! CCAction]
        
        self.player.runAction((CCActionSpawn.actionWithArray(arrActions) as! CCActionFiniteTime) as CCAction)
    }
    
    //Colisoes
    
    //TIRO PLAYER AVIAO
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, TiroPlayer anTiro:TiroPlayer!, Aviao anAviao:Aviao!) -> Bool {
        
        anAviao.atirar()
        anAviao.removeFromParentAndCleanup(true)
        anTiro.removeFromParentAndCleanup(true)
        self.adicionarPontos(100)
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, TiroPlayer anTiro:TiroPlayer!, TiroInimigo anTiroInimigo:TiroInimigo!) -> Bool {
        
        anTiroInimigo.removeFromParentAndCleanup(true)
        anTiro.removeFromParentAndCleanup(true)
        adicionarPontos(50)
        return true
    }
    
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, Pessoa anPessoa:Pessoa!, TiroInimigo anTiroInimigo:TiroInimigo!) -> Bool {
        anTiroInimigo.removeFromParentAndCleanup(true)
        anPessoa.removeFromParentAndCleanup(true)
        contabilizaPessoa()
        return true
    }
    
    func boolAleatorio() -> Bool {
        return arc4random_uniform(2) == 0 ? true: false
    }
    
    func adicionarPontos(pontos:Int){
        self.score=score+pontos
        self.scoreLabel.string = "Score: \(score)"
    }
    
    func contabilizaTiro(){
        //self.tirosDados=self.tirosDados+1
        //self.tirosDadosLabel.string = "Tiros: \(tirosDados)"
    }
    
    func contabilizaPessoa(){
        
        if(self.vidas==0){
            self.gameOver()
        }
        
        
        self.vidas=self.vidas-1
        self.life.string = "Life: \(self.vidas)"
    }
    
    func gameOver(){
        self.gameOverLabel.visible = true
        self.canPlay = false
        for item in self.physicsWorld.children {
            
            item.stopAllActions()
            
            if let pessoa =  item as? Pessoa{
                pessoa.stopAll()
            }
            
            if let aviao =  item as? Aviao{
                aviao.stopAll()
            }
            
        }
    }
}
