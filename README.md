# BSP-Swift-dungeon-Generator
A Swift 4.2 translation of [this tutorial](https://gamedevelopment.tutsplus.com/tutorials/how-to-use-bsp-trees-to-generate-game-maps--gamedev-12268)
# Usage: 
Download the files "Generator.swift" and "GameScene.swift" and drop them into your *.xcodeproject* or simply copy/paste the code into wherever you need it. The code is formatted and commented. It has been tested and is working.  

To initialize a custom map: 

`map = TileEngine(TileEngine(tileSize: CGSize(width: Int, height: Int), columns: Int, rows: Int)`

Because the dungeons are procedurally generated, no two dungeon will ever generate the same.
