const rl = @import("raylib");
const Rectangle = rl.Rectangle;
pub const TileSize = 16;

pub const TileTag = enum {
    dirt, //= // Vector2(0, 0),
    dirt_wall_top_left, //= //Vector2(1, 0),
    dirt_wall_top, //= //Vector2(2, 0),
    dirt_wall_top_right, //= //Vector2(2, 0),
    dirt_gravel, //= //Vector2(0, 1),
    dirt_Wall_left, //= //Vector2(1, 1),
    dirt_Wall, //= //Vector2(2, 1),
    dirt_Wall_right, //= //Vector2(2, 1),
    dirt_stone_gravel, //= //Vector2(0, 2),
    dirt_wall_bottom_left, //= //Vector2(1, 2),
    dirt_wall_bottom, //= //Vector2(2, 2),
    dirt_wall_bottom_right, //= //Vector2(2, 3),
    floor,
    empty,
};

pub fn getTileRect(tile: TileTag) rl.Rectangle {
    var r = Rectangle{ .height = TileSize, .width = TileSize, .x = 0, .y = 0 };
    switch (tile) {
        .dirt, .empty => {},
        .dirt_wall_top_left => {
            r.x = 1;
            r.y = 0;
        },
        .dirt_wall_top => {
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
