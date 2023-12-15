// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const ts = @import("dungeon_tileset.zig");
const raylib = @import("raylib.zig");

const tile_tags = std.ComptimeStringMap(ts.Tile, .{
    .{ "f", .floor },
    .{ "w", .wall },
    .{ "e", .empty },
});

const State = struct {
    tile_index_position: raylib.Vector2 = undefined,
    tile: ?ts.Tile = null,
    entropy: i16 = -1,
};

const TileStates = std.MultiArrayList(State);

pub fn main() anyerror!void {
    const mapWith = 2;
    _ = mapWith;
    const mapHeight = 2;
    _ = mapHeight;
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920 / 2;
    const screenHeight = 1080 / 2;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var tiles = TileStates{};
    defer {
        const deinit_status = gpa.deinit();
        //fail test; can't try in defer as defer is executed after we return
        if (deinit_status == .leak) std.testing.expect(false) catch @panic("TEST FAIL");
    }
    defer tiles.deinit(alloc);
    // init grid map
    // load in sample map
    const buffer = try alloc.alloc(u8, 1024 * 2);
    defer alloc.free(buffer);
    const contents = try std.fs.cwd().readFile(
        "assets/map_sample.csv",
        buffer,
    );
    var lineItr = std.mem.splitAny(u8, contents, "\n\r");
    // classify the tile to wall floor or empty, in order to deterimne if it is walkable or collidable
    var x: f32 = 0;
    var y: f32 = 0;
    while (lineItr.next()) |line| {
        var tokenItr = std.mem.splitAny(u8, line, ",");
        defer y += 1;
        while (tokenItr.next()) |token| {
            defer x += 1;
            if (token.len == 0) break;
            const tile = tile_tags.get(token) orelse break;
            try tiles.append(alloc, .{
                .tile = tile,
                .tile_index_position = .{ .x = x, .y = y },
                .entropy = -1,
            });
        }
    }
    raylib.SetConfigFlags(raylib.FLAG_VSYNC_HINT);
    raylib.InitWindow(screenWidth, screenHeight, "");
    defer raylib.CloseWindow(); // Close window and OpenGL context

    raylib.SetTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    const tilemapTexture = raylib.LoadTexture("assets/sample.png");
    defer raylib.UnloadTexture(tilemapTexture);
    const camera: raylib.Camera2D = .{ .offset = .{
        .x = 0,
        .y = 0,
    }, .rotation = 0, .target = .{
        .y = 0,
        .x = 0,
    }, .zoom = 3.0 };
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
        raylib.DrawTexture(tilemapTexture, 0, 0, raylib.WHITE);

        defer raylib.EndMode2D();

        //----------------------------------------------------------------------------------
    }
}
