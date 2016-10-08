class TiroInimigo : CCSprite {
    // MARK: - Public Objects
    var damage:CGFloat = 0.0
    
    // MARK: - Private Objects
    
    // MARK: - Life Cycle

    override init(CGImage image: CGImage!, key: String!) {
        super.init(CGImage: image, key: key)
    }
    
    override init(spriteFrame: CCSpriteFrame!) {
        super.init(spriteFrame: spriteFrame)
    }
    
    override init(texture: CCTexture!) {
        super.init(texture: texture)
    }
    
    override init(texture: CCTexture!, rect: CGRect) {
        super.init(texture: texture, rect: rect)
    }
    
    override init(texture: CCTexture!, rect: CGRect, rotated: Bool) {
        super.init(texture: texture, rect: rect, rotated: rotated)
    }
    
    override init(imageNamed imageName: String!) {
        super.init(imageNamed: imageName)
    }
    
    convenience override init() {
        self.init(imageNamed:"box\(Int(arc4random_uniform(4) + 1)).png")
        
        self.physicsBody = CCPhysicsBody(rect: CGRectMake(0, 0, self.contentSize.width, self.contentSize.height), cornerRadius: 0.0)
        self.physicsBody.type = CCPhysicsBodyType.Kinematic
        self.physicsBody.friction = 1.0
        self.physicsBody.elasticity = 0.1
        self.physicsBody.mass = 100.0
        self.physicsBody.density = 100.0
        self.physicsBody.collisionType = "TiroInimigo"
        self.physicsBody.collisionCategories = ["TiroInimigo"]
        self.physicsBody.collisionMask = ["Pessoa","TiroPlayer"]
    }
    
    override func onEnter() {
        super.onEnter()
    }
    
    func movaMeParaPosicao(posicao:CGPoint){
        // Movimenta o disparo ateh a posicao do player
        self.runAction(CCActionSequence.actionOne(CCActionMoveTo.actionWithDuration(5, position:CGPointMake(posicao.x, -100)) as! CCActionFiniteTime, two: CCActionCallBlock.actionWithBlock({ () -> Void in
            self.removeFromParentAndCleanup(true)
        }) as! CCActionFiniteTime) as! CCAction)
    }
    
    deinit {
        // Chamado no momento de desalocacao
    }
}
