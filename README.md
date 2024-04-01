# BSP-Swift-dungeon-Generator
A Swift 4.2 translation of [this tutorial.](https://gamedevelopment.tutsplus.com/tutorials/how-to-use-bsp-trees-to-generate-game-maps--gamedev-12268) When I was developing a side project, Apple's SKTileMap framework was riddled with bugs and did not cut it for me. So I wrote my own based off of the above tutorial to compensate. 

## Usage: 
Download the files "Generator.swift" and "GameScene.swift" and drop them into your *.xcodeproject* or simply copy/paste the code into wherever you need it. The code is formatted and commented. It has been tested and is working.  

To initialize a custom map: 

`map = TileEngine(tileSize: CGSize(width: Int, height: Int), columns: Int, rows: Int)`

Because the dungeons are procedurally generated, no two dungeons will ever generate the same.

## Trouble-shooting

When you implement the algorithm and build and run it, you might see a white image with a red X on it. This is because the tile definitions in the `TileEngine.swift` file have not been provided a texture to display. 

By default, the tile map is set to a scale of 0.2 to provide an easy viewing angle. You need to go into the `TileEngine.swift` file and remove the line `tileMap.setScale(0.2)` from the bottom of the `init()` method. 

*Note: This is not a tutorial on how to make SKTileMapNodes work. This is an algorithm to generate SKTileMapNodes using BSP trees. Tutorials on SKTileMapNodes can be found elsewhere.*
