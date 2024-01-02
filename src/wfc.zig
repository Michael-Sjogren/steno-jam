const std = @import("std");
const raylib = @import("raylib.zig");
const Rand = std.rand.Random;
pub const WFC = @This();

//
input_width: u32,
input_height: u32,
input: []WFCTile,

// world grid
wold_width: u32,
world_height: u32,
grid: []WFCTile,
rng: Rand,

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
    sample_id: usize,

    pub fn updateConstraints(
        self: *WFCTile,
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

            y = @mod(y, height);
            x = @mod(x, width);

            self.possibleTiles[i] = @intCast(x * y);
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
pub fn waveFunctionCollapse(self: *WFC) ![]WFCTile {
    // first select a random tile with the least entropy
    const index = self.rng.intRangeAtMost(usize, 0, self.world_height * self.wold_width);
    const sample_index = self.rng.intRangeAtMost(usize, 0, self.input_width * self.input_height);
    var tile = self.grid[index];
    tile.sample_id = sample_index;
    tile.currentIndex = index;

    // also select a random cell in the world

}

pub fn isAllCollapsed(self: *WFC) bool {
    for (self.grid) |*tile| {
        if (!tile.collapsed) {
            return false;
        }
    }
    return true;
}

test "test wfc" {}
