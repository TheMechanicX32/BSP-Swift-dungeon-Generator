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
    
    var v = CGVector()
    
    var xJoystickDelta = CGFloat()
    var yJoystickDelta = CGFloat()
    
    var DPad = SKSpriteNode()
    var thumbNode = SKSpriteNode()
    
    var isTracking = Bool()
    
    var map = TileEngine(tileSize: CGSize(width: 32, height: 32), columns: 50, rows: 50)
    
    override func didMove(to view: SKView) {
        
        thumbNode.size = CGSize(width: 50, height: 50)
        DPad.size = CGSize(width: 150, height: 150)
        DPad.position = CGPoint(x: -230, y: -80)
        thumbNode.position = DPad.position
        DPad.zPosition = 3
        thumbNode.zPosition = 4
        DPad.texture = SKTexture(imageNamed: "base")
        thumbNode.texture = SKTexture(imageNamed: "stick")

        self.addChild(DPad)
        self.addChild(thumbNode)
        self.addChild(map)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if isTracking == false && DPad.contains(location) {
                isTracking = true
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location: CGPoint = touch.location(in: self)
            if isTracking == true {
                
                v = CGVector(dx: location.x - DPad.position.x, dy: location.y - DPad.position.y)
                let angle = atan2(v.dy, v.dx)
                //let deg = angle * CGFloat(180 / Double.pi)
                
                let Length:CGFloat = DPad.frame.size.height / 2
                let xDist: CGFloat = sin(angle - 1.57079633) * Length
                let yDist: CGFloat = cos(angle - 1.57079633) * Length
                
                xJoystickDelta = location.x - DPad.position.x
                yJoystickDelta = location.y - DPad.position.y
                
                if DPad.contains(location) {
                    thumbNode.position = location
                } else {
                    thumbNode.position = CGPoint(x: DPad.position.x - xDist, y: DPad.position.y + yDist)
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTracking = false
        thumbNode.run(SKAction.move(to: DPad.position, duration: 0.01))
        xJoystickDelta = 0
        yJoystickDelta = 0
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        let xScale = CGFloat(0.1) //adjust to your preference
        let yScale = CGFloat(0.1) //adjust to your preference
        
        let xAdd = xScale * self.xJoystickDelta
        let yAdd = yScale * self.yJoystickDelta
        
        map.position.x -= xAdd
        map.position.y -= yAdd
    }
}
