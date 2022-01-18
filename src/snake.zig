const std = @import("std");
const w4 = @import("wasm4.zig");

pub const Point = struct {
    x: i32,
    y: i32,
    pub fn init(x: i32, y: i32) @This() {
        return @This(){
            .x = x,
            .y = y,
        };
    }

    pub fn equals(this: @This(), other: @This()) bool {
        return (this.x == other.x) and (this.y == other.y);
    }
};

pub const Snake = struct {
    body: std.BoundedArray(Point, 400),
    direction: Point,

    pub fn init() @This() {
        return @This(){
            .body = std.BoundedArray(Point, 400).fromSlice(&.{
                Point.init(2, 0),
                Point.init(1, 0),
                Point.init(0, 0),
            }) catch @panic("couldn't init snake body"),
            .direction = Point.init(1, 0),
        };
    }

    pub fn draw(this: @This()) void {
        w4.DRAW_COLORS.* = 0x0043;
        for (this.body.constSlice()) |part| {
            w4.rect(.{ part.x * 8, part.y * 8 }, .{ 8, 8 });
        }
        w4.DRAW_COLORS.* = 0x0004;
        w4.rect(.{ this.body.get(0).x * 8, this.body.get(0).y * 8 }, .{ 8, 8 });
    }

    pub fn update(this: *@This()) void {
        const part = this.body.slice();
        var i: u32 = part.len - 1;
        while (i > 0) : (i -= 1) {
            part[i].x = part[i - 1].x;
            part[i].y = part[i - 1].y;
        }

        part[0].x = @mod((part[0].x + this.direction.x), 20);
        part[0].y = @mod((part[0].y + this.direction.y), 20);

        if (part[0].x < 0) part[0].x = 19;
        if (part[0].y < 0) part[0].y = 19;
    }
    pub fn up(this: *@This()) void {
        if (this.direction.y == 0) {
            this.direction.x = 0;
            this.direction.y = -1;
        }
    }
    pub fn down(this: *@This()) void {
        if (this.direction.y == 0) {
            this.direction.x = 0;
            this.direction.y = 1;
        }
    }
    pub fn left(this: *@This()) void {
        if (this.direction.x == 0) {
            this.direction.x = -1;
            this.direction.y = 0;
        }
    }
    pub fn right(this: *@This()) void {
        if (this.direction.x == 0) {
            this.direction.x = 1;
            this.direction.y = 0;
        }
    }
};
