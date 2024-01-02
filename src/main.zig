// raylib-zig (c) Nikolas Wipper 2023
const std = @import("std");
const wfc = @import("wfc.zig");
const raylib = @import("raylib.zig");
const Rectangle = raylib.Rectangle;
const RndGen = std.rand.DefaultPrng;
const TileSize = 16;
const json = std.json;

/// TODO LIST
///
/// The game must feature:
/// - [] multiple rooms containing either a door to the next floor, hostile entities, treasure, equiptment, and/or empty space
/// - [] multiple floors consisting of rooms
/// - [] difficulty increasing as the player ventures deeper incrementing the floor index
/// - [] hostile entities that move between rooms
/// - [] potions (or equivalent) to restore health
/// - [] potions (or equivalent) to restore stamina and/or mana equivalent
/// - [] a health system where damage varies based on equiptment currently in use
/// - [] a companion (dog, fellow adventurer, or similar) which the player may recruit
/// - [] permanent death (die and you start again) with persistance (can find their body from a previous run)
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

    raylib.SetConfigFlags(raylib.FLAG_VSYNC_HINT);
    raylib.InitWindow(screenWidth, screenHeight, "Stank");

    defer raylib.CloseWindow(); // Close window and OpenGL context
    const sampleTilemapTexture = raylib.LoadTexture("assets/samples/small-sample.png");
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
    _ = sample_size;
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
    const textureRectPos = wfc.indexToPositionV2(0, width, TileSize);
    const textureRect: Rectangle = .{
        .width = TileSize,
        .height = TileSize,
        .x = textureRectPos.x,
        .y = textureRectPos.y,
    };
    _ = textureRect;
    const tile_ids = try loadSampleData(alloc, "assets/samples/small-sample.tmj");
    std.debug.assert(sample_width * sample_height == tile_ids.len);

    while (!raylib.WindowShouldClose()) { // Detect window close button or ESC key
        defer raylib.ClearBackground(raylib.RAYWHITE);
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        raylib.BeginMode2D(camera);
        defer raylib.EndMode2D();
        raylib.DrawTexture(sampleTilemapTexture, 0, 0, raylib.WHITE);
    }
}

pub fn loadSampleData(alloc: anytype, path: []const u8) ![]u32 {
    const Data = struct {
        data: []u32,
        height: u32 = 0,
        width: u32 = 0,
    };

    const T = struct {
        height: u32 = 0,
        width: u32 = 0,
        tilewidth: u32 = 0,
        tileheight: u32 = 0,
        layers: []Data,
    };
    const buffer = try alloc.alloc(u8, 1024 * 20);
    defer alloc.free(buffer);
    const contents = try std.fs.cwd().readFile(
        path,
        buffer,
    );

    var parser = try json.parseFromSlice(
        T,
        alloc,
        contents,
        .{ .ignore_unknown_fields = true },
    );

    defer parser.deinit();

    return parser.value.layers[0].data;
}
