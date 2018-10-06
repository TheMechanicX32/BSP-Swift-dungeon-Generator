//
//  Generator.swift
//  Dungeon Pirates
//
//  Created by HuckStudio on 10/1/18.
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
                            // If split worked, push child leafs into vector
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
        let Tiles = SKTileSet(named: "Dungeon")
        let TileGroups = Tiles?.tileGroups
        
        let tile1 = SKTexture(imageNamed: "black")
        let tile2 = SKTexture(imageNamed: "door")
        
        let black = SKTileDefinition(texture: tile1, size: tileSize)
        let red = SKTileDefinition(texture: tile2, size: tileSize)
        
        let tileGroup1 = SKTileGroup(tileDefinition: black)
        let tileGroup2 = SKTileGroup(tileDefinition: red)
        let tileGroup3 = TileGroups![0]
        
        let tileSet = SKTileSet(tileGroups: [tileGroup1,tileGroup2, tileGroup3])
        
        let tileMap = SKTileMapNode(tileSet: tileSet, columns: columns, rows: rows, tileSize: tileSize)
        
        for c in 0..<tileMap.numberOfColumns {
            for r in 0..<tileMap.numberOfRows {
                for i in 0..<rooms.count {
                    // iterate through each room and carve it out
                    if rooms[i].x1 <= c && rooms[i].x2 >= c && rooms[i].y1 <= r && rooms[i].y2 >= r {
                        tileMap.setTileGroup(tileGroup2, forColumn: c, row: r)
                    } else if tileMap.tileGroup(atColumn: c, row: r) != tileGroup2 && tileMap.tileGroup(atColumn: c, row: r) != tileGroup3 {
                        tileMap.setTileGroup(tileGroup1, forColumn: c, row: r)
                    }
                }
                for h in 0..<hallways.count {
                    // iterate through each hallway and carve it out
                    if hallways[h].x1 <= c && hallways[h].x2 >= c && hallways[h].y1 <= r && hallways[h].y2 >= r {
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

class Leaf {
    public var minLeafSize = 6
    
    public var x, y, width, height:Int
    
    public var leftChild:Leaf?
    public var rightChild:Leaf?
    public var room:Room?
    public var hallways = [Room]()
    
    init(X:Int, Y:Int, W:Int, H:Int) {
        x = X
        y = Y
        width = W
        height = H
    }
    
    public func split() -> Bool {
        // Split leaf into 2 children
        if (leftChild != nil || rightChild != nil) { return false }
        // Already split
    
        // Determine split direction
        // If width >25% larger than height, split vertically
        // Otherwise if height >25% larger than width, split horizontally
        // if none of these, split randomly
        var splitH:Bool = Int.random(in: 0..<100) > 50 ? true : false
    
        if width > height && Double(height / width) >= 1.25 {
            splitH = false;
        } else if height > width && Double(width / height) >= 1.25 {
            splitH = true;
        }
    
        let max = (splitH ? height : width) - minLeafSize // determine the maximum height or width
        if max <= minLeafSize { return false } // the area is too small to split any more...
    
        // determine where we're going to split
        let split = Int.random(in: minLeafSize..<max)//Int(arc4random_uniform(UInt32(max + minLeafSize) - UInt32(minLeafSize)))
    
        // Create children based on split direction
        if (splitH) {
            leftChild = Leaf(X: x, Y: y, W: width, H: split);
            rightChild = Leaf(X: x, Y: y + split, W: width, H: height - split)
        } else {
            leftChild = Leaf(X: x, Y: y, W: split, H: height);
            rightChild = Leaf(X: x + split, Y: y, W: width - split, H: height)
        }
        return true
    }
    func getRoom() -> Room? {
        
        if let _ = room {
            return room
        } else {
        
            let lRoom = leftChild?.getRoom()
            let rRoom = rightChild?.getRoom()
        
            switch (lRoom != nil, rRoom != nil) {
            case (false,false):
                return nil
            case (true,false):
                return lRoom
            case (false,true):
                return rRoom
            case (true,true):
                return Double.random(in: 0..<1.0) > 0.5 ? lRoom : rRoom
            }
        }
    }
    
    public func createRooms() {
    // Generates all rooms and hallways for this leaf and its children
        if leftChild != nil || rightChild != nil {
            // This leaf has been split, go to children leafs
            if leftChild != nil {
                leftChild!.createRooms()
            }
            if rightChild != nil {
                rightChild!.createRooms()
            }
            // If there are both left and right children in leaf, make hallway between them
            if leftChild != nil && rightChild != nil {
                // If there is a room in either the left or right leaves
                guard let leftRoom = leftChild!.getRoom(), let rightRoom = rightChild!.getRoom() else { return }
                
                // If there is, create a hall between them
                createHall(left: leftRoom, right: rightRoom)
                print(hallways.count)
            }
        } else if Int.random(in: 0..<100) > 25 {
            // Room can be between 3x3 tiles to (leaf.size - 2)
            let xSize = Int.random(in: 3..<(width - 2))
            let ySize = Int.random(in: 3..<(height - 2))
            let roomSize = CGPoint(x: xSize, y: ySize)
            
            // Place the room within leaf, but not against sides. It would merge with other rooms.
            let roomPos = CGPoint(x: Int.random(in: 2..<(width - Int(roomSize.x))),
                                  y: Int.random(in: 2..<(height - Int(roomSize.y))))
            
            room = Room(X: x + Int(roomPos.x), Y: y + Int(roomPos.y), W: Int(roomSize.x), H: Int(roomSize.y))
        }
    }
    public func createHall(left:Room, right:Room) {
        // Connects 2 rooms together with hallways
        hallways = []
    
        // get width and height of first room
        let point1 = CGPoint(x: Int.random(in: (left.x1 + 1)..<(left.x2 - 1)),
                             y: Int.random(in: (left.y1 + 1)..<(left.y2 - 1)))
        
        // get width and height of second room
        let point2 = CGPoint(x: Int.random(in: (right.x1 + 1)..<(right.x2 - 1)),
                             y: Int.random(in: (right.y1 + 1)..<(right.y2 - 1)))
        
        let w = point2.x - point1.x
        let h = point2.y - point1.y
        
        if w < 0 {
            if h < 0 {
                if Double.random(in: 0..<1.0) > 0.5 {
                    hallways.append(Room(X: Int(point2.x), Y: Int(point1.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: 1, H: Int(abs(h))))
                } else {
                    hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point1.x), Y: Int(point2.y), W: 1, H: Int(abs(h))))
                }
            } else if h > 0 {
                if Double.random(in: 0..<1.0) > 0.5 {
                    hallways.append(Room(X: Int(point2.x), Y: Int(point1.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point2.x), Y: Int(point1.y), W: 1, H: Int(abs(h))))
                } else {
                    hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: 1, H: Int(abs(h))))
                }
            } else {
                hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: Int(abs(w)), H: 1))
            }
        } else if w > 0 {
            if h < 0 {
                if Double.random(in: 0..<1.0) > 0.5 {
                    hallways.append(Room(X: Int(point1.x), Y: Int(point2.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point1.x), Y: Int(point2.y), W: 1, H: Int(abs(h))))
                } else {
                    hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: 1, H: Int(abs(h))))
                }
            } else if h > 0 {
                if Double.random(in: 0..<1.0) > 0.5 {
                    hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point2.x), Y: Int(point1.y), W: 1, H: Int(abs(h))))
                } else {
                    hallways.append(Room(X: Int(point1.x), Y: Int(point2.y), W: Int(abs(w)), H: 1))
                    hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: 1, H: Int(abs(h))))
                }
            } else {
                hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: Int(abs(w)), H: 1))
            }
        } else {
            if h < 0 {
                hallways.append(Room(X: Int(point2.x), Y: Int(point2.y), W: 1, H: Int(abs(h))))
            } else if h > 0 {
                hallways.append(Room(X: Int(point1.x), Y: Int(point1.y), W: 1, H: Int(abs(h))))
            }
        }
    }
}
// A basic helper class to determine the size and position of the rooms.
class Room {
    var x1:Int
    var x2:Int
    var y1:Int
    var y2:Int
    var center:CGPoint
    
    init(X: Int, Y: Int, W: Int, H: Int) {
        x1 = X
        x2 = X + W
        y1 = Y
        y2 = Y + H
        center = CGPoint(x: (x1 + x2) / 2, y: (y1 + y2) / 2)
    }
}



