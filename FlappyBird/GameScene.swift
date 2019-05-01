//
//  GameScene.swift
//  FlappyBird
//
//  Created by Ricardo Hui on 30/4/2019.
//  Copyright © 2019 Ricardo Hui. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOver = false
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
    
    enum ColliderType : UInt32{
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
  
    @objc func makePipes(){
        let movePipes = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.height / 4
        let pipe1Texture = SKTexture(imageNamed: "pipe1")
        let pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipe1Texture.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(movePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe1.zPosition = -1
        self.addChild(pipe1)
        
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2")
        let pipe2  = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipe2Texture.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(movePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipe1Texture.size())
        pipe2.physicsBody!.isDynamic = false
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe2.zPosition = -1
        self.addChild(pipe2)
        
        
        
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipe1Texture.size().width, height: gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(movePipes)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
        
    }
    
    override func didMove(to view: SKView) {
        
        self.physicsWorld.contactDelegate = self
        setUpGame()
      
    }
    
    func setUpGame(){
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        
        let bgTexture = SKTexture(imageNamed: "bg")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy:0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,shiftBGAnimation]))
        
        var i : CGFloat = 0
        
        while i < 3{
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.run(moveBGForever)
            bg.zPosition = -2
            self.addChild(bg)
            i += 1
        }
        
        
        let birdTexture = SKTexture(imageNamed: "flappy1")
        let birdTexture2 = SKTexture(imageNamed: "flappy2")
        
        let animation = SKAction.animate(with: [birdTexture, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture.size().height / 2 )
        bird.physicsBody!.isDynamic = false
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        
        
        self.addChild(bird)
        
        let ground  = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height / 2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic = false
        
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        self.addChild(scoreLabel)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false{
            if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue{
                print("Add one to score")
                score += 1
                scoreLabel.text = String(score)
            }else{
                print("We have contact!")
                self.speed = 0
                gameOver = true
                timer.invalidate()
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again."
                gameOverLabel.position =  CGPoint(x:self.frame.midX, y: self.frame.midY)
                self.addChild(gameOverLabel)
            }
        }
        
      
        
    }
    
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameOver{
            bird.physicsBody!.isDynamic = true
            bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
            bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        }else{
            score = 0
            self.speed = 1
            gameOver = false
            self.removeAllChildren()
            setUpGame()
        }
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
