// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const rl = @import("raylib");
const ts = @import("dungeon_tileset.zig");
pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920 / 2;
    const screenHeight = 1080 / 2;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};

    const alloc = gpa.allocator();

    var canidates = try ts.getTileCandiates(alloc);

    defer {
        ts.freeTileCanidatesMap(&canidates);
        const leak = gpa.detectLeaks();
        if (leak) {
            std.debug.print("Leaked", .{});
        }
        _ = gpa.deinit();
    }

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    var tilemapTexture = rl.loadTexture("assets/tilesets/tilemap_packed.png");
    defer tilemapTexture.unload();
    const camera: rl.Camera2D = .{ .offset = .{
        .x = 0,
        .y = 0,
    }, .rotation = 0, .target = .{
        .y = 0,
        .x = 0,
    }, .zoom = 3.0 };
    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.beginMode2D(camera);
        defer rl.endMode2D();
        //rl.drawTexture(tilemapTexture, 0, 0, rl.Color.white);

        rl.drawTextureRec(tilemapTexture, ts.getTileRect(.dirt), .{
            .x = 0,
            .y = 0,
        }, rl.Color.white);

        rl.clearBackground(rl.Color.white);

        //----------------------------------------------------------------------------------
    }
}
