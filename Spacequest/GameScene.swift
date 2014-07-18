import SpriteKit


class GameScene: SKScene {
    
    var background: BackgroundNode
    var playerSpaceship: PlayerSpaceship
    
    init(size: CGSize) {
        
        background = BackgroundNode(size: size)
        playerSpaceship = PlayerSpaceship()
        
        super.init(size: size)
        
        //background.configureInScene(self)
        configurePlayerSpaceship()
        configurePhysics()
    }
    
    override func didMoveToView(view: SKView) {
    
    }

   
    override func update(currentTime: CFTimeInterval) {

    
    
    }
    
    
    func launchEnemySpaceship() {
    
        var enemySpaceship = EnemySpaceship(health: 20)
        
        // Determine where to spawn the enemy along the Y axis.
        let minY = enemySpaceship.size.height/2 + 220.0
        let maxY = frame.size.height - enemySpaceship.size.height/2 - 50.0
        let rangeY = maxY - minY
        let randomY: UInt32 = arc4random_uniform(UInt32(rangeY)) + UInt32(minY)
        
        // Set position of the enemy to be slightly off-screen along the right edge,
        // and along a random position along the Y axis.
        enemySpaceship.position = CGPoint(x: frame.size.width + enemySpaceship.size.width/2, y: CGFloat(randomY))
        
        self.addChild(enemySpaceship)
        
        // Determine speed of the enemy.
        let enemyFlightDuration = 5.0
        let moveAction = SKAction.moveToX(-enemySpaceship.size.width/2, duration: enemyFlightDuration)
        
        enemySpaceship.runAction(SKAction.sequence([moveAction, SKAction.removeFromParent()]))
    }
}


/**
 Configuration.
*/
extension GameScene {
    
    func configurePhysics() {
        
        physicsWorld.gravity = CGVectorMake(0,0);
        physicsWorld.contactDelegate = self;
    }

    
    func configurePlayerSpaceship() {
        
        playerSpaceship.position = CGPoint(x: playerSpaceship.size.width/2 + 30.0, y: self.frame.size.height/2 + 40.0);
        
        playerSpaceship.health = 100
        self.addChild(playerSpaceship)
    }
}


/**
 Collisions.
*/
extension GameScene : SKPhysicsContactDelegate {
    
    func didBeginContact(contact: SKPhysicsContact!) {
        
    }
}

