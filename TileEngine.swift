//
//  TileEngine.swift
//

import Foundation
import SpriteKit

struct point {
    var x: Int
    var y: Int
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
        hallways = [];
    
        // Get width and height of first room
        let point1 = point(x: Int.random(in: (left.x1 + 1)..<(left.x2 - 1)),
                           y: Int.random(in: (left.y1 + 1)..<(left.y2 - 1)))
        
        // Get width and height of second room
        let point2 = point(x: Int.random(in: (right.x1 + 1)..<(right.x2 - 1)),
                           y: Int.random(in: (right.y1 + 1)..<(right.y2 - 1)))
        
        if Bool.random() {
            // Horizontally first, then vertically:
            // From point1 to min(point2.x, point1.y):
            hallways.append(Room(X: min(point1.x, point2.x), Y: point1.y,
                                 W: Int(abs(point1.x - point2.x)), H: 0))
            // From (point2.x, point1.y) to point2:
            hallways.append(Room(X: point2.x, Y: min(point1.y, point2.y),
                                 W: 0, H: Int(abs(point1.y - point2.y))))
        } else {
            // Vertically first, then Horizontally:
            // From point1 to min(point1.x, point2.y):
            hallways.append(Room(X: point1.x, Y: min(point1.y, point2.y),
                                 W: 0, H: Int(abs(point1.y - point2.y))))
            // From (point1.x, point2.y) to point2:
            hallways.append(Room(X: min(point1.x, point2.x), Y: point2.y,
                                 W: Int(abs(point1.x - point2.x)), H: 0))
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
