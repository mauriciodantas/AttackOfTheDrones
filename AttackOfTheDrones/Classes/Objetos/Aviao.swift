// MARK: - Class Definition
internal class Aviao : CCNode {
    
    internal var targetID:AnyObject?
    

    private var alive:Bool = true
    private var spriteAviao:CCSprite!
    var tempoProximoTiro:Double!
    var velocidadeMinima:Double!
    var atirou:Bool = false
    var tiro:TiroInimigo!
    var posicaoEsquerda:Bool!
    
    // MARK: - Life Cycle
    override init() {
        super.init()
        
        //self.spriteAviao = CCSprite(imageNamed: "aviao\(Int(arc4random_uniform(3) + 1)).png")
        self.spriteAviao = self.gerarAnimacaoSpriteWithName("drone\(Int(arc4random_uniform(2	) + 1))", aQtdFrames: 2)
        self.spriteAviao.anchorPoint = CGPointMake(0.0, 0.0);
        self.spriteAviao.position = CGPointMake(0.0, 0.0);
        self.addChild(self.spriteAviao, z:1)
        
        // Determina sua area para touch (contentSize) - baseado no anchorpoint 0,0
        self.contentSize = self.spriteAviao!.boundingBox().size
        
        self.physicsBody = CCPhysicsBody(rect: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), cornerRadius: 0.0)
        self.physicsBody.type = CCPhysicsBodyType.Kinematic
        self.physicsBody.friction = 1.0
        self.physicsBody.elasticity = 0.1
        self.physicsBody.mass = 100.0
        self.physicsBody.density = 100.0
        self.physicsBody.collisionType = "Aviao"
        self.physicsBody.collisionCategories = ["Aviao"]
        self.physicsBody.collisionMask = ["TiroPlayer"]
        
        
    }
    
    convenience init(target:AnyObject, tempoEntreTiros:Double, velocidadeMinimaPercurso:Double, esquerda:Bool) {
        self.init()
        self.targetID = target
        self.tempoProximoTiro = tempoEntreTiros
        self.velocidadeMinima = velocidadeMinimaPercurso
        self.posicaoEsquerda = esquerda
        
        self.tiro = TiroInimigo()
        self.tiro.anchorPoint = CGPointMake(0.5, 0.5)
        self.tiro.position = CGPointMake(0.0, 0.0)
        self.tiro.visible = false
        
        let target = self.targetID as! GameScene
        target.physicsWorld.addChild(tiro)
        
        if(!posicaoEsquerda){
            self.scaleX = -1
        }
        
        DelayHelper.sharedInstance.callFunc("atirar", onTarget: self, withDelay:tempoProximoTiro)
    }
    
    override func onEnter() {
        // Chamado apos o init quando entra no director
        super.onEnter()
    }
    
    // MARK: - Public Methods
    internal func moveMe() {
        
        let speed:CGFloat = CGFloat(arc4random_uniform(7))+CGFloat(self.velocidadeMinima)
        
        var posicaoFinal = CGPointMake(1100, self.position.y)
        
        if(!self.posicaoEsquerda){
            posicaoFinal = CGPointMake(-100, self.position.y)

        }
        
        
        self.runAction(CCActionSequence.actionOne(CCActionMoveTo.actionWithDuration(CCTime(speed), position: posicaoFinal) as! CCActionFiniteTime,
            two: CCActionCallBlock.actionWithBlock({ _ in
                self.removeFromParentAndCleanup(true)
            }) as! CCActionFiniteTime)
            as! CCAction)
    }
    
    internal func width() -> CGFloat {
        return self.spriteAviao!.boundingBox().size.width
    }
    
    internal func height() -> CGFloat {
        return self.spriteAviao!.boundingBox().size.height
    }
    
    func atirar(){
        self.atirou = true
        self.tiro.physicsBody.type = CCPhysicsBodyType.Dynamic
    }
    
    override func update(delta: CCTime) {
        if(!atirou){
            self.tiro.position = CGPointMake(self.position.x, self.position.y-40)
        }
        self.tiro.visible = true
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
    
    func stopAll() {
        self.stopAllActions()
        self.spriteAviao!.stopAllActions()
    }
    
    deinit {
    }
}
