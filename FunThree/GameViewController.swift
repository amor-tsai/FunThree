//
//  GameViewController.swift
//  FunThree
//
//  Created by Amor on 2021/10/13.
//

import Foundation
import UIKit
import SpriteKit

class GameViewController:UIViewController {
    
    @IBOutlet weak var GameSKView: SKView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //
        //setup game scene
        let scene = GameScene(size: GameSKView.bounds.size)
        
        GameSKView.showsFPS = true // show some debugging of the FPS
        GameSKView.showsNodeCount = true // show how many active objects are in the scene
        GameSKView.ignoresSiblingOrder = true // don't track who entered scene first
        scene.scaleMode = .resizeFill
        GameSKView.presentScene(scene)
        
    }

}
