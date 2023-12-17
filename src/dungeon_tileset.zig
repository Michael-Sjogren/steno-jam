const rl = @import("raylib.zig");
const std = @import("std");
const ArrayList = std.ArrayList;
const Rectangle = rl.Rectangle;
pub const TileSize: i32 = 16;

pub const north: u8 = 0;
pub const east: u8 = 1;
pub const west: u8 = 2;
pub const south: u8 = 3;

pub const TileNeighbour = struct {
    directions: u8,
    tile: Tile,
};
pub const TileNeighbours = std.ArrayList(TileNeighbour);

pub const CanidatesMap = std.AutoArrayHashMap(Tile, TileNeighbours);

// inner means a wall that is MORE visible inside the walls
// outer means a wall that has more of its exterior visible
pub const Tile = enum(u8) {
    empty,
    floor,
    wall,
};

// need to store if diffrent tile rotations is compatiable witch each other
// need to store what tile this tile can have as compatible neighbour

/// Returns a rectangle where that tile texture is located in the tileset.
pub fn getTileRect(tile: Tile) rl.Rectangle {
    var r = Rectangle{ .height = TileSize, .width = TileSize, .x = 0, .y = 0 };
    switch (tile) {
        .dirt, .empty => {},
    }

    r.x *= TileSize;
    r.y *= TileSize;

    return r;
}

pub fn getTileCandiates(
    alloc: anytype,
) !CanidatesMap {
    const canidates = CanidatesMap.init(alloc);
    // define tiles that are compatiable together
    const info = @typeInfo(Tile);
    _ = info;
    return canidates;
}

pub fn freeTileCanidatesMap(map: *CanidatesMap) void {
    map.clearAndFree();
    map.deinit();
}
