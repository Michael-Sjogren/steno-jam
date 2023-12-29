// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const wfc = @import("wfc.zig");
const raylib = @import("raylib.zig");
const Rectangle = raylib.Rectangle;
const RndGen = std.rand.DefaultPrng;
const TileSize = 16;
const json = std.json;
const tile_tags = std.ComptimeStringMap(wfc.Tile, .{
    .{ "F", .floor },
    .{ "W", .wall },
    .{ "E", .empty },
});

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
    const sampleTilemapTexture = raylib.LoadTexture("assets/sample.png");
    defer raylib.UnloadTexture(sampleTilemapTexture);
    const sample_width: i32 = @divFloor(
        @as(i32, @intCast(sampleTilemapTexture.width)),
        TileSize,
    );
    const sample_height: i32 = @divFloor(
        @as(i32, @intCast(sampleTilemapTexture.height)),
        TileSize,
    );

    const sample_size: usize = @intCast(sample_width * sample_height);
    std.log.debug("contents \n{s}", .{contents});
    const lineItr = std.mem.splitAny(u8, contents, "\n");
    _ = lineItr;
    // load the sample tiles and the information about each tile in the sample.csv
    std.log.debug("map dim x {d} y {d}", .{ sample_width, sample_height });
    const index: i32 = 0;

    std.log.debug("INDEX {d}, sample_size size area {d} ", .{ index, sample_size });

    const world_width: u32 = 8;
    const world_height: u32 = 8;
    // INITIALIZE WORLD
    var worldTiles: [world_width * world_height]wfc.Tile = [_]wfc.Tile{.{
        .tile_id = 0,
        .tile_type = .floor,
        .position = .{},
        .index = 0,
    }} ** (world_width * world_height);
    // POPULATE SET WORLD POS OF EACH TILE
    for (&worldTiles, 0..) |*tile, i| {
        tile.*.index = i;
        tile.*.position = wfc.indexToPositionV2(i, world_width, TileSize);
        tile.*.tile_type = .empty;
        tile.*.tile_id = @intCast((sample_width) * (sample_height));
    }
    // collapse
    raylib.SetTargetFPS(60); // Set our gafileme to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    const camera: raylib.Camera2D = .{ .offset = .{
        .x = 0,
        .y = 0,
    }, .rotation = 0, .target = .{
        .y = 0,
        .x = 0,
    }, .zoom = 3.0 };
    const width: u32 = @intCast(sample_width);

    // Main game loop
    var textureRectPos = wfc.indexToPositionV2(0, width, TileSize);
    var textureRect: Rectangle = .{
        .width = TileSize,
        .height = TileSize,
        .x = textureRectPos.x,
        .y = textureRectPos.y,
    };

    try loadSampleData(alloc, "assets/samples/small-sample.tmj");

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
        //raylib.DrawTexture(tilemapTexture, 0, 0, raylib.WHITE);
        for (worldTiles) |tile| {
            //if (tile.tile_type == .empty) continue;
            textureRectPos = wfc.indexToPositionV2(
                tile.tile_id,
                (width),
                TileSize,
            );
            textureRect.x = textureRectPos.x;
            textureRect.y = textureRectPos.y;
            raylib.DrawTextureRec(
                sampleTilemapTexture,
                textureRect,
                tile.position,
                raylib.WHITE,
            );
        }
        //----------------------------------------------------------------------------------
    }
}

pub fn loadSampleData(alloc: anytype, path: []const u8) !void {
    _ = path;
    var parsed = try std.json.parseFromSlice(u8, alloc, sample_json, .{});
    defer parsed.deinit();
    std.log.debug("{}", .{parsed.value});
}
