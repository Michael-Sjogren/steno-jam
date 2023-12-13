const rl = @import("raylib");
const std = @import("std");
const ArrayList = std.ArrayList;
const Rectangle = rl.Rectangle;
pub const TileSize = 16;

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
    sand,
    Wall_inner_north, //2, 1
    wall_inner_north_west_edge, //1, 0
    wall_inner_north_edge, //2, 0
    wall_inner_north_east_edge, //2, 0
    Wall_inner_east_edge, //= // 2, 1
    wall_inner_west_edge, //1, 1
    wall_south_west_edge, //1, 2
    wall_south_edge, //2, 2
    wall_south_east_Edge, //2, 3
    dirt_stone_gravel, // 0, 2
    dirt_gravel, //0, 1
    dirt, //0, 0
};

// need to store if diffrent tile rotations is compatiable witch each other
// need to store what tile this tile can have as compatible neighbour

/// Returns a rectangle where that tile texture is located in the tileset.
pub fn getTileRect(tile: Tile) rl.Rectangle {
    var r = Rectangle{ .height = TileSize, .width = TileSize, .x = 0, .y = 0 };
    switch (tile) {
        .dirt, .empty => {},
        .wall_north_west_edge => {
            r.x = 1;
            r.y = 0;
        },
        .wall_south_facing => {
            r.x = 2;
            r.y = 0;
        },
        .dirt_wall_top_right => {
            r.x = 3;
            r.y = 0;
        },
        .dirt_gravel => {
            r.x = 0;
            r.y = 1;
        },
        .dirt_Wall_left => {
            r.x = 1;
            r.y = 1;
        },
        .dirt_Wall => {
            r.x = 2;
            r.y = 1;
        },
        .dirt_Wall_right => {
            r.x = 2;
            r.y = 1;
        },
        .dirt_stone_gravel => {
            r.x = 0;
            r.y = 2;
        },
        .dirt_wall_bottom_left => {
            r.x = 1;
            r.y = 2;
        },
        .dirt_wall_bottom => {
            r.x = 2;
            r.y = 2;
        },
        .dirt_wall_bottom_right => {
            r.x = 2;
            r.y = 3;
        },
        .floor => {
            r.x = 0;
            r.y = 4;
        },
    }

    r.x *= TileSize;
    r.y *= TileSize;

    return r;
}

pub fn getTileCandiates(
    alloc: anytype,
) !CanidatesMap {
    var canidates = CanidatesMap.init(alloc);
    // define tiles that are compatiable together
    const info = @typeInfo(Tile);
    var i: u8 = 0;
    inline for (info.Enum.fields) |_| {
        const t: Tile = @enumFromInt(i);
        try canidates.put(t, TileNeighbours.init(alloc));
        i += 1;
    }
    // dirt canidates
    canidates.put(.dirt, canidates.get(.dirt).?.appendSlice(&.{
        .{
            .tile = .dirt,
            .directions = east | west | north | south,
        },
        .{
            .tile = .dirt_Wall,
            .directions = south,
        },
        .{ .tile = .dirt_wall_bottom },
    }));
    return canidates;
}

pub fn freeTileCanidatesMap(map: *CanidatesMap) void {
    map.clearAndFree();
    map.deinit();
}
