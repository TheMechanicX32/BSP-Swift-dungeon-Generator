//
//  TileEngine.swift
//  Dungeon Pirates
//
//  Created by HuckStudio on 10/8/18.
//  Copyright © 2018 HucksCorp. All rights reserved.
//

import Foundation
import SpriteKit

// A class to help translate generated data into a visual tile map
class TileEngine: SKNode {
    
    var rooms = [Room]()
    var hallways = [Room]()
    var leaves = [Leaf]()
    
    init(tileSize: CGSize, columns: Int, rows: Int) {
        super.init()
        
        rooms = [];
        hallways = [];
        leaves = [];
        
        let maxLeafSize = 20
        
        // First, create leaf to be root of all leaves
        let root = Leaf(X: 0, Y: 0, W: columns, H: rows);
        leaves.append(root)
        
        var didSplit:Bool = true;
        
        // Loop through every Leaf in array until no more can be split
        while (didSplit) {
            didSplit = false;
            for leaf in leaves {
                if leaf.leftChild == nil && leaf.rightChild == nil { // If not split
                    // If this leaf is too big, or 75% chance
                    if leaf.width > maxLeafSize || leaf.height > maxLeafSize || Int.random(in: 0..<100) > 25 {
                        if (leaf.split()) { // split the leaf
                            // If split worked, push child leaves into array
                            leaves.append(leaf.leftChild!)
                            leaves.append(leaf.rightChild!)
                            didSplit = true
                        }
                    }
                }
            }
        }
        // Next, iterate through each leaf and create room in each one
        root.createRooms()
        
        for leaf in leaves {
            // Then draw room and hallway (if there is one)
            if leaf.room != nil {
                drawRoom(roomRect: leaf.room!)
            }
            if leaf.hallways.isEmpty != true {
                drawHall(hallRect: leaf.hallways)
            }
        }
        // Initialize a tile map and give it content to build with
        
        // A 32x32 black texture
        let tile1 = SKTexture(imageNamed: "black")
        
        // A 32x32 red texture
        let tile2 = SKTexture(imageNamed: "red")
        
        let black = SKTileDefinition(texture: tile1, size: tileSize)
        let red = SKTileDefinition(texture: tile2, size: tileSize)
        
        let tileGroup1 = SKTileGroup(tileDefinition: black)
        let tileGroup2 = SKTileGroup(tileDefinition: red)
        
        let tileSet = SKTileSet(tileGroups: [tileGroup1,tileGroup2])
        
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        
        for c in 0..<tileMap.numberOfColumns {
            for r in 0..<tileMap.numberOfRows {
                for i in rooms {
                    // iterate through each room and carve it out
                    if i.x1 <= c && i.x2 >= c && i.y1 <= r && i.y2 >= r {
                        tileMap.setTileGroup(tileGroup2, forColumn: c, row: r)
                    } else if tileMap.tileGroup(atColumn: c, row: r) != tileGroup2 && tileMap.tileGroup(atColumn: c, row: r) != tileGroup3 {
                        tileMap.setTileGroup(tileGroup1, forColumn: c, row: r)
                    }
                }
                for h in hallways {
                    // iterate through each hallway and carve it out
                    if h.x1 <= c && h.x2 >= c && h.y1 <= r && h.y2 >= r {
                        tileMap.setTileGroup(tileGroup2, forColumn: c, row: r)
                    } else if tileMap.tileGroup(atColumn: c, row: r) != tileGroup2 && tileMap.tileGroup(atColumn: c, row: r) != tileGroup3 {
                        tileMap.setTileGroup(tileGroup1, forColumn: c, row: r)
                    }
                }
            }
        }
        
        self.addChild(tileMap)
        tileMap.setScale(0.2)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawRoom(roomRect: Room) {
        rooms.append(roomRect)
    }
    func drawHall(hallRect: [Room]) {
        for rect in hallRect {
            hallways.append(rect)
        }
    }
}
