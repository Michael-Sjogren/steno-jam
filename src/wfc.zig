const std = @import("std");
const raylib = @import("raylib.zig");
pub const WFC = @This();

//
input_width: u32,
input_height: u32,
input: []WFCTile,

// world grid
wold_width: u32,
world_height: u32,
grid: []WFCTile,

pub const TileType = enum(u8) {
    empty,
    floor,
    wall,
};

// tile for final map
pub const Tile = struct {
    tile_id: usize, // tileset id
    tile_type: TileType,
    index: usize,
    position: raylib.Vector2,
};

pub const WFCTile = struct {
    // possible tile indexes from the sample tileset
    // north,east,west,south
    possibleTiles: [4]?usize = .{ null, null, null, null },
    collapsed: bool = false,
    currentIndex: usize,

    pub fn observe(self: *WFCTile) u8 {
        _ = self;

        return 0;
    }

    pub fn updateConstraints(
        self: *WFCTile,
        tile: *WFCTile,
        width: u32,
        height: u32,
    ) void {
        var x: i32 = 0;
        var y: i32 = 0;

        // 0 1 2
        // 3 4 5
        // 6 7 8
        var i = 0;
        for (9) |n| {
            x = @mod(
                @as(u32, self.currentIndex),
                width,
            );
            y = @divFloor(
                @as(u32, @bitCast(self.currentIndex)),
                height,
            );

            x = @mod(
                @as(u32, tile.currentIndex),
                width,
            );
            y = @divFloor(
                @as(u32, tile.currentIndex),
                width,
            );
            switch (n) {
                0, 2, 4, 6, 8 => continue,
                1 => {
                    y += 1;
                },
                3 => {
                    x += -1;
                },
                5 => {
                    x += 1;
                },
                7 => {
                    y += -1;
                },
            }
            defer i += 1;
            //const validGridTile = world_width >= x1 and x1 > 0 and world_height >= y1 and y1 > 0;
            if (width >= x and x > 0 and height >= y and y > 0) {
                self.possibleTiles[i] = @intCast(x * y);
                //world_tile.possibleTiles[i] = @intCast(x1 * y1);
            }
        }
    }

    pub fn countAdjacent(self: *WFCTile) u16 {
        var count: u16 = 0;
        for (self.possibleTiles) |maybeIndex| {
            count += @intFromBool(maybeIndex != null);
        }
        return count;
    }
};

pub fn propagate(self: *WFC, world_tile: *WFCTile) !void {
    world_tile.updateAdjacent(self.wold_width, self.world_height);
}

pub fn indexToPositionV2(index: usize, map_width: u32, tile_size: u32) raylib.Vector2 {
    return raylib.Vector2{
        .x = @floatFromInt(
            @mod(index, map_width) * tile_size,
        ),
        .y = @floatFromInt(
            @divFloor(
                index,
                map_width,
            ) * tile_size,
        ),
    };
}

// returns a final grid after it is done
pub fn waveFunctionCollapse(self: *WFC) ![]Tile {
    _ = self;
}
