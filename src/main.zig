// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const ts = @import("dungeon_tileset.zig");
const raylib = @import("raylib.zig");
const Rectangle = raylib.Rectangle;

const tile_tags = std.ComptimeStringMap(ts.Tile, .{
    .{ "F", .floor },
    .{ "W", .wall },
    .{ "E", .empty },
});

const Point = struct {
    x: i32 = 0,
    y: i32 = 0,
};

const State = struct {
    tile_index_position: Point,
    tile: ?ts.Tile = null,
    entropy: i16 = -1,
};

const TileStates = std.ArrayList(State);

pub fn calcEntropy(
    input_width: i32,
    input_height: i32,
    tile_x: i32,
    tile_y: i32,
) !i16 {
    var entropy: i16 = 0;

    // 0 1 2
    // 3 4 5
    // 6 7 8

    // (-1,-1) (0,-1) (1,-1)
    // (-1, 0) (0, 0) (1, 0)
    // (-1, 1) (0, 1) (1, 1)

    for (0..8) |i| {
        switch (i) {
            0, 4, 2, 6, 8 => continue, // skip diagonal adjacent tiles
            else => {},
        }
        const index: i32 = @intCast(i);
        const dir_x: i32 = @mod(index, 3) - 1;
        const dir_y: i32 = @divFloor(index, 3) - 1;
        if (input_width - 1 >= tile_x + dir_x and
            tile_x + dir_x >= 0 and
            input_height - 1 >= tile_y + dir_y and
            tile_y + dir_y >= 0)
        {
            entropy += 1;
        }
    }

    return entropy;
}

test "calcAdjacentTiles" {
    std.testing.log_level = .debug;

    var result = try calcEntropy(
        4,
        4,
        4,
        4,
    );

    try std.testing.expectEqual(
        @as(i16, 0),
        result,
    );

    result = try calcEntropy(
        4,
        4,
        1,
        1,
    );

    try std.testing.expectEqual(
        @as(i16, 4),
        result,
    );

    result = try calcEntropy(
        2,
        2,
        2,
        1,
    );

    try std.testing.expectEqual(
        @as(i16, 1),
        result,
    );

    result = try calcEntropy(
        4,
        4,
        9,
        9,
    );

    try std.testing.expectEqual(
        @as(i16, 0),
        result,
    );
}

pub fn main() anyerror!void {

    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920 / 2;
    const screenHeight = 1080 / 2;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const alloc = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }

    // init grid map
    // load in sample map
    const buffer = try alloc.alloc(u8, 1024 * 4);
    defer alloc.free(buffer);
    const contents = try std.fs.cwd().readFile(
        "assets/map_sample.csv",
        buffer,
    );

    raylib.SetConfigFlags(raylib.FLAG_VSYNC_HINT);
    raylib.InitWindow(screenWidth, screenHeight, "Stank");

    defer raylib.CloseWindow(); // Close window and OpenGL context
    const tilemapTexture = raylib.LoadTexture("assets/sample.png");
    defer raylib.UnloadTexture(tilemapTexture);
    const sample_width: i32 = @divFloor(@as(i32, @intCast(tilemapTexture.width)), ts.TileSize);
    const sample_height: i32 = @divFloor(@as(i32, @intCast(tilemapTexture.height)), ts.TileSize);

    const map_size: usize = @intCast(sample_width * sample_height);
    var tiles = try TileStates.initCapacity(alloc, map_size);
    defer tiles.deinit();
    std.log.debug("contents \n{s}", .{contents});
    var lineItr = std.mem.splitAny(u8, contents, "\n");
    // classify the tile to wall floor or empty, in order to deterimne if it is walkable or collidable

    std.log.debug("map dim x {d} y {d}", .{ sample_width, sample_height });
    var i: i32 = 0;
    while (lineItr.next()) |line| {
        std.log.debug("line: {s}", .{line});
        var tokenItr = std.mem.splitAny(u8, line, ",");
        while (tokenItr.next()) |token| {
            const tile = tile_tags.get(token) orelse {
                std.log.debug("unkown token {s}", .{token});
                break;
            };
            defer i += 1;

            const x = @mod(
                i,
                sample_width,
            );

            const y =
                @divFloor(
                i,
                sample_width,
            );

            const t_x = x;
            const t_y = y;

            std.log.debug("tile x: {d}, tile y: {d}", .{
                t_x,
                t_y,
            });

            try tiles.append(.{
                .tile = tile,
                .tile_index_position = .{ .x = t_x, .y = t_y },

                .entropy = try calcEntropy(
                    sample_width,
                    sample_height,
                    t_x,
                    t_y,
                ),
            });
        }
    }

    std.log.debug("INDEX {d}, map size area {d} ", .{ i, map_size });
    std.debug.assert(i == map_size);
    raylib.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    const camera: raylib.Camera2D = .{ .offset = .{
        .x = 0,
        .y = 0,
    }, .rotation = 0, .target = .{
        .y = 0,
        .x = 0,
    }, .zoom = 1.0 };

    const stdout = std.io.getStdOut();
    defer stdout.close();
    const writer = stdout.writer();

    try printMap(writer, &tiles, @bitCast(sample_width), @bitCast(sample_height));
    // Main game loop
    while (!raylib.WindowShouldClose()) { // Detect window close button or ESC key
        defer raylib.ClearBackground(raylib.RAYWHITE);

        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        raylib.BeginMode2D(camera);
        defer raylib.EndMode2D();
        raylib.DrawTexture(tilemapTexture, 0, 0, raylib.WHITE);

        //----------------------------------------------------------------------------------
    }
}

pub fn printMap(writer: anytype, map: *std.ArrayList(State), map_width: u32, map_height: u32) !void {
    _ = map_height;

    for (map.items, 0..) |*tileInfo, i| {
        const index: u32 = @intCast(i);
        if (@mod(index, map_width) == 0) {
            try writer.print("\n", .{});
        }

        try writer.print(" {d} ", .{tileInfo.entropy});
    }
}
