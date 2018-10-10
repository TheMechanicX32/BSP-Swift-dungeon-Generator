//
//  GameScene.swift
//  

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Initialize a new BSP map.
    var map = TileEngine(tileSize: CGSize(width: 32, height: 32), columns: 50, rows: 50)
    
    override func didMove(to view: SKView) {
        self.addChild(map)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
