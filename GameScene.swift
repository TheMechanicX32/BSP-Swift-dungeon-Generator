//
//  GameScene.swift
//  Dungeon Pirates
//
//  Created by HuckStudio on 9/5/18.
//  Copyright © 2018 HucksCorp. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var map = TileEngine(tileSize: CGSize(width: 32, height: 32), columns: 50, rows: 50)
    
    override func didMove(to view: SKView) {
        self.addChild(map)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
    }
}
