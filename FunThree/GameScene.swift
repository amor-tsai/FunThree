//
//  GameScene.swift
//  FunThree
//
//  Created by Amor on 2021/10/13.
//

import Foundation
import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {

    //@IBOutlet weak var scoreLabel: UILabel!
    
    // MARK: Raw Motion Functions
    let motion = CMMotionManager()
    let motionModel = {
        return MotionModel.sharedInstance()
    }()
    
    private let GAME_COST = 1 // each time add a picachu, cost 1 coin
    
    func startMotionUpdates(){
        // if motion is available, start updating the device motion
        if self.motion.isDeviceMotionAvailable{
            self.motion.deviceMotionUpdateInterval = 0.2
            self.motion.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: self.handleMotion )
        }
    }
    
    func handleMotion(_ motionData:CMDeviceMotion?, error:Error?){
        // make gravity in the game als the simulator gravity
        if let gravity = motionData?.gravity {
            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: CGFloat(9.8*gravity.y))
//            self.physicsWorld.gravity = CGVector(dx: CGFloat(9.8*gravity.x), dy: 0)
            
//            if (spinBlock.position.x <= spinBlock.size.width/2 && gravity.x < 0) || (spinBlock.position.x >= self.size.width-spinBlock.size.width/2 && gravity.x > 0) {
//                return
//            } else {
//                print("spinblock size: \(spinBlock.size.width)  pos: \(spinBlock.position.x) grax: \(gravity.x) gray: \(gravity.y) ")
            let action = SKAction.moveBy(x: gravity.x * 200, y: 0, duration: 0.5)
            spinBlock.run(action)
//            }
        }
        
    }
    
    
    // MARK: View Hierarchy Functions
    // this is like out "View Did Load" function
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundColor = SKColor.white
        
        // start motion for gravity
        self.startMotionUpdates()
        
        // make sides to the screen
        self.addSidesAndTop()
        
        // add some stationary blocks on left and right
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.1, y: size.height * 0.25))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.9, y: size.height * 0.25))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.2, y: size.height * 0.25))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.3, y: size.height * 0.7))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.4, y: size.height * 0.25))
        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.8))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.6, y: size.height * 0.7))
//        self.addStaticBlockAtPoint(CGPoint(x: size.width * 0.7, y: size.height * 0.25))
        
        // add a spinning block
        self.addBlockAtPoint(CGPoint(x: size.width * 0.5, y: size.height * 0.25))
        
        // add in the interaction picachu
        self.addPicachu()
        
        // add a scorer
        self.addScore()
        
        // add currency
        self.addCurrency()
        
        // update a special watched property for score
        self.score = 0
    }
    
    // MARK: Create Sprites Functions
    let spinBlock = SKSpriteNode(imageNamed: "hat")
    let scoreLabel = SKLabelNode(fontNamed: "Arial")
    let currencyLable = SKLabelNode(fontNamed: "Arial")
    var score:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async{
                self.scoreLabel.text = "Score: \(newValue)"
            }
        }
    }
    var currency:Int = 0 {
        willSet(newValue){
            DispatchQueue.main.async {
                self.currencyLable.text = "Coin: \(newValue)"
            }
        }
    }
    
    func addScore(){
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 20
        scoreLabel.fontColor = SKColor.blue
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.minY)
        
        addChild(scoreLabel)
    }
    
    func addCurrency(){
        self.motionModel.setUpCurrency()
        self.currency = motionModel.getCurrency()
        print("currency: \(self.currency)")
        
        currencyLable.text = "Coin: \(self.currency)"
        currencyLable.fontSize = 20
        currencyLable.fontColor = SKColor.blue
        currencyLable.position = CGPoint(x: frame.minX+60, y: frame.minY)
        
        addChild(currencyLable)
    }
    
    func addPicachu(){
        if false == self.motionModel.updateCurrency(number: -1) {
            return
        } else {
            self.currency = self.motionModel.getCurrency()
        }
        
//        let picachuTexture = SKTexture(imageNamed: "picachu")
        let picachu = SKSpriteNode(imageNamed: "picachu") // this is a picachu
        
        picachu.size = CGSize(width:size.width*0.2,height:size.height * 0.1)
        
        let randNumber = random(min: CGFloat(0.1), max: CGFloat(0.9))
        picachu.position = CGPoint(x: size.width * randNumber, y: size.height * 0.75)
        
        picachu.physicsBody = SKPhysicsBody(rectangleOf:picachu.size)
//        picachu.physicsBody = SKPhysicsBody(texture: picachuTexture, size: CGSize(width: picachu.size.width*0.1, height: picachu.size.height*0.05))
        picachu.physicsBody?.restitution = random(min: CGFloat(1), max: CGFloat(4))
        picachu.physicsBody?.isDynamic = true
        // for collision detection we need to setup these masks
        picachu.physicsBody?.contactTestBitMask = 0x00000001
        picachu.physicsBody?.collisionBitMask = 0x00000001
        picachu.physicsBody?.categoryBitMask = 0x00000001
        
//        picachu.physicsBody?.applyImpulse(CGVector(dx: 0, dy: -9.8))
        
        self.addChild(picachu)
    }
    
    func addBlockAtPoint(_ point:CGPoint){
        
        spinBlock.color = UIColor.green
        spinBlock.size = CGSize(width:size.width*0.2,height:size.height * 0.1)
        spinBlock.position = point
        
        spinBlock.physicsBody = SKPhysicsBody(rectangleOf: spinBlock.size)
        spinBlock.physicsBody?.contactTestBitMask = 0x00000001
        spinBlock.physicsBody?.collisionBitMask = 0x00000001
        spinBlock.physicsBody?.categoryBitMask = 0x00000001
        spinBlock.physicsBody?.isDynamic = true
        spinBlock.physicsBody?.affectedByGravity = false
//        spinBlock.physicsBody?.pinned = true
        spinBlock.physicsBody?.allowsRotation = true
        spinBlock.physicsBody?.angularDamping = 0.4
        spinBlock.physicsBody?.mass = 100 // so the picachu would not crush the hat to fall down
        spinBlock.physicsBody?.restitution = random(min: CGFloat(0.5), max: CGFloat(2.7))
//        spinBlock.constraints = [SKConstraint.positionY(SKRange(constantValue: spinBlock.position.y))]
        
        
        self.addChild(spinBlock)

    }
    
    func addStaticBlockAtPoint(_ point:CGPoint){
        
        let block = SKSpriteNode(imageNamed: "ball")
        
        block.color = UIColor.green
        block.size = CGSize(width:size.width*0.16,height:size.height * 0.08)
        block.position = point
        
        block.physicsBody = SKPhysicsBody(circleOfRadius: block.size.width/2)
        block.physicsBody?.isDynamic = true
        block.physicsBody?.pinned = true
        block.physicsBody?.allowsRotation = true
        
        block.physicsBody?.contactTestBitMask = 0x00000001
        block.physicsBody?.collisionBitMask = 0x00000001
        block.physicsBody?.categoryBitMask = 0x00000001
        
        self.addChild(block)
        
    }
    
    func addSidesAndTop(){
        let left = SKSpriteNode(imageNamed: "wall-texture")
        let right = SKSpriteNode(imageNamed: "wall-texture")
        let top = SKSpriteNode(imageNamed: "wall-texture")
        
        left.size = CGSize(width:size.width*0.1,height:size.height)
        left.position = CGPoint(x:0, y:size.height*0.5)
        
        right.size = CGSize(width:size.width*0.1,height:size.height)
        right.position = CGPoint(x:size.width, y:size.height*0.5)
        
        top.size = CGSize(width:size.width,height:size.height*0.05)
        top.position = CGPoint(x:size.width*0.5, y:size.height)
        
        for obj in [left,right,top]{
            obj.color = UIColor.green
            obj.physicsBody = SKPhysicsBody(rectangleOf:obj.size)
            obj.physicsBody?.isDynamic = false
            obj.physicsBody?.pinned = true
            obj.physicsBody?.allowsRotation = false
            obj.physicsBody?.contactTestBitMask = 0x00000001
            obj.physicsBody?.collisionBitMask = 0x00000001
            obj.physicsBody?.categoryBitMask = 0x00000001
            self.addChild(obj)
        }
    }
    
    // MARK: =====Delegate Functions=====
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.addPicachu()
    }
    
    // here is our collision function
    func didBegin(_ contact: SKPhysicsContact) {
        // if anything interacts with the spin Block, then we should update the score
        if contact.bodyA.node == spinBlock || contact.bodyB.node == spinBlock {
            spinBlock.physicsBody?.velocity.dy = 0
            self.score += 1
        }
        
        
        // TODO: How might we add additional scoring mechanisms?
    }
    
    // MARK: Utility Functions (thanks ray wenderlich!)
    // generate some random numbers for cor graphics floats
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / Float(Int.max))
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
}
