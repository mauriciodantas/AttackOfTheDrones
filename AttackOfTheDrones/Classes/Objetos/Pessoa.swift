// MARK: - Class Definition
internal class Pessoa : CCNode {
    
    internal var targetID:AnyObject?
    
    // MARK: - Private Objects
    private var alive:Bool = true
    private var spritePessoa:CCSprite!
    var tempoProximoTiro:Double!
    var velocidadeMinima:Double!
    var esquerda:Bool!
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        self.spritePessoa = self.gerarAnimacaoSpriteWithName("guy\(Int(arc4random_uniform(4) + 1))", aQtdFrames: 2)
        //self.spritePessoa = CCSprite(imageNamed: "guy\(Int(arc4random_uniform(4) + 1)).png")
        self.spritePessoa.anchorPoint = CGPointMake(0.0, 0.0);
        self.spritePessoa.position = CGPointMake(0.0, 0.0);
        self.addChild(self.spritePessoa, z:1)
        
        // Determina sua area para touch (contentSize) - baseado no anchorpoint 0,0
        self.contentSize = self.spritePessoa!.boundingBox().size
        
        self.physicsBody = CCPhysicsBody(rect: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), cornerRadius: 0.0)
        self.physicsBody.type = CCPhysicsBodyType.Kinematic
        self.physicsBody.friction = 1.0
        self.physicsBody.elasticity = 0.1
        self.physicsBody.mass = 100.0
        self.physicsBody.density = 100.0
        self.physicsBody.collisionType = "Pessoa"
        self.physicsBody.collisionCategories = ["Pessoa"]
        self.physicsBody.collisionMask = ["TiroInimigo"]
    }
    
    convenience init(target:AnyObject, velocidadeMinimaPercurso:Double, posicaoEsquerda:Bool) {
        self.init()
        self.targetID = target
        self.velocidadeMinima = velocidadeMinimaPercurso
        self.esquerda = posicaoEsquerda
        
        if(!esquerda){
            self.scaleX = -1
        }
    }
    
    override func onEnter() {
        super.onEnter()
    }
    

    internal func moveMe() {
        
        let speed:CGFloat = CGFloat(arc4random_uniform(7))+CGFloat(self.velocidadeMinima)
        
        var posicaoDestino = CGPointMake(2000, self.position.y)
        
        if(!esquerda){
            posicaoDestino = CGPointMake(-20, self.position.y)
        }
        
        self.runAction(CCActionSequence.actionOne(CCActionMoveTo.actionWithDuration(CCTime(speed), position: posicaoDestino) as! CCActionFiniteTime,
            two: CCActionCallBlock.actionWithBlock({ _ in
                self.removeFromParentAndCleanup(true)
            }) as! CCActionFiniteTime)
        as! CCAction)
    }
    
    
    func gerarAnimacaoSpriteWithName(aSpriteName:String, aQtdFrames:Int) -> CCSprite {
        // Carrega os frames da animacao dentro do arquivo passado dada a quantidade de frames
        var animFrames:Array<CCSpriteFrame> = Array()
        for (var i = 1; i <= aQtdFrames; i++) {
            let name:String = "\(aSpriteName)\(i).png"
            animFrames.append(CCSpriteFrameCache.sharedSpriteFrameCache().spriteFrameByName(name))
        }
        // Cria a animacao dos frames montados
        let animation:CCAnimation = CCAnimation(spriteFrames: animFrames, delay: 0.1)
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
    
    
    internal func width() -> CGFloat {
        return self.spritePessoa!.boundingBox().size.width
    }
    
    internal func height() -> CGFloat {
        return self.spritePessoa!.boundingBox().size.height
    }
    
    func stopAll() {
        self.stopAllActions()
        self.spritePessoa!.stopAllActions()
    }
    
    deinit {
    }
}
