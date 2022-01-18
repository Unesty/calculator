const w4 = @import("wasm4.zig");
const std = @import("std");
const Snake = @import("snake.zig").Snake;
var snake = Snake.init();
var prev_state1: u8 = 0;
pub const Vec2 = @import("std").meta.Vector(2, i32);
const sin = std.math.sin;
fn sinI(n: anytype, amplitude: f32, wavetime: f32) i32 {
    //     switch(@TypeOf(n)) {
    //         i32 => return @floatToInt(i32, std.math.absFloat(sin(@intToFloat(f32, n)))*amplitude),
    //         u128 => return @floatToInt(i32, std.math.absFloat(sin(@intToFloat(f32, n)))*amplitude),
    //         else => {
    //             return 0;
    //         }
    //     }
    return @floatToInt(i32, std.math.absFloat(sin(@intToFloat(f32, n) * wavetime)) * amplitude);
}
const cos = std.math.cos;
const tan = std.math.tan;
const absI = std.math.absInt;
const abs = std.math.absFloat;

fn distance(a: Vec2, b: Vec2) i32 {
    var c: Vec2 = a - b;
    var d: i32 = c[0] * c[0] + c[1] * c[1];
    var s: f32 = std.math.sqrt(@intToFloat(f32, d));
    return @floatToInt(i32, @round(s));
}

var time: i32 = 0;
var mpos: Vec2 = Vec2{ 0, 0 };
var dragstart: Vec2 = Vec2{ -1, -1 };
var dragstartul: Vec2 = Vec2{ 10, 10 };
// var mouse: w4.Mouse = w4.Mouse

// function pointers can grow up size quickly

fn defaultPress(self: *Button) void {
    self.state = Button.States.pressed;
    w4.tone(w4.ToneFrequency{ .start = 200 }, w4.ToneDuration{ .decay = 4 }, 50, w4.ToneFlags{ .channel = w4.ToneFlags.Channel.pulse1, .mode = w4.ToneFlags.Mode.p12_5 });
    dragstart = mpos;
    dragstartul = self.*.ul;
}

fn defaultPressed(self: *Button) void {
    var prevcolor = w4.DRAW_COLORS.*;
    w4.text("some pressed button function", self.*.ul + Vec2{15, 0});
    w4.DRAW_COLORS.* = 0x1;
    self.*.ul = dragstartul + mpos - dragstart;
    w4.oval(self.*.ul, self.*.wh);
    w4.DRAW_COLORS.* = prevcolor;
    w4.tone(w4.ToneFrequency{ .start = 200 }, w4.ToneDuration{ .decay = 4 }, 50, w4.ToneFlags{ .channel = w4.ToneFlags.Channel.pulse1, .mode = w4.ToneFlags.Mode.p12_5 });
}

fn defaultRelease(self: *Button) void {
    self.state = Button.States.idle;
}

fn defaultIdle(self: * Button) void {
    w4.oval(self.*.ul, self.*.wh);
    w4.text("some text", self.*.ul + Vec2{15, 0});
}

fn defaultHover(self: * Button) void {
    var prevcolor = w4.DRAW_COLORS.*;
    w4.DRAW_COLORS.* = 0x0043;
    w4.oval(self.*.ul, self.*.wh);
    w4.DRAW_COLORS.* = prevcolor;
}

const bFn = [_]fn (self: * Button) void{ defaultIdle, defaultHover, defaultPress };

const Button = struct {
    const Self = @This(); // how to use this?
    pub const States = enum(u2){
        idle,
        hovered,
        pressed,
    };
    onPress: fn (self: * Button) void = defaultPress, // array of functions that button call when pressed
    onPressed: fn (self: * Button) void = defaultPressed,
    onRelease: fn (self: * Button) void = defaultRelease,
    ul: Vec2 = Vec2{ 10, 10 },
    wh: Vec2 = Vec2{ 10, 10 },
    color: u2 = 0,
    onIdle: u8 = 0, //id of function to call on idle to draw button
    onHover: u8 = 1,
    state: States = States.idle,
    pub fn isInRect(self: Self, point: Vec2) bool {
        if ((point[0] > self.ul[0]) and (point[0] < self.ul[0] + self.wh[0]) and (point[1] > self.ul[1]) and (point[1] < self.ul[1] + self.wh[1])) {
            return true;
        } else {
            return false;
        }
    }
    pub fn isInCircle(self: Self, point: Vec2) bool {
        if (distance(Vec2{ self.ul[0] + @divFloor(self.wh[0], 2) + 1, self.ul[1] + @divFloor(self.wh[1], 2) + 1 }, point) < @divFloor(self.wh[0], 2)) {
            return true;
        } else {
            return false;
        }
    }
};
var btns: [100]Button = [1]Button{.{
    .color = undefined,
}} ** 100;
// var btnsImg: [160*160]u2 = undefined; //takes much memory
// fn drawBtns() void {
//     for (btns) |btn, i| {
//         if (btns[i].color != 0) {
//             // btn.ul, btn.wh, btn.color);
//             var x: u8 = 0;
//             var y: u8 = 0;
//             while(x < btn.wh[0] and y < btn.wh[1]) {
//                 x+=1;
//                 y+=1;
//                 btnsImg[(x+btn.ul[0])*(y+btn.ul[1])] = btns[i].color;
//             }
//         } else {
//             break;
//         }
//     }
// }

export fn start() void {
    btns[0] = Button{ .color = 3 };
    btns[1] = Button{ .color = 3, .ul = Vec2{ 30, 40 } };
    //     drawBtns();
    w4.PALETTE.* = .{
        0,
        0x333333,
        0x090999,
        0x00ffff,
    };
}
export fn update() void {
    time += 1;
    input();
    //     draw GUI
    //     w4.blit(btnsImg, .{0, 0}, .{160, 160}, w4.BLIT_2BPP); //to draw button framebuffer

    //     w4.PALETTE.* = .{
    //         @intCast(u32, time),
    //         @floatToInt(u32, std.math.absFloat(sin(@intToFloat(f32, time) / 100) * 60)),
    //         0xff33ff,
    //         0x234567,
    //     };

    w4.oval(.{ 10, 10 }, .{ 10, @floatToInt(i32, abs(sin(@intToFloat(f32, time) / 100) * 60)) });
    w4.text("GAEM\n YES", .{ (sinI(time, 160, 1 / 160)), 20 });
    for (w4.FRAMEBUFFER.*) |*x| {
        x.* = @intCast(u8, sinI(time + @intCast(i32, @ptrToInt(x)), 2, 56)) << 3;
    }
    if (@intCast(u32, time) % 5 == 0)
        snake.update();
    snake.draw();
    for (btns) |btn, i| {
        if (btn.color != 0) {
            //
            if (btn.isInCircle(mpos)) {
                if (w4.MOUSE.*.buttons.left) {
                    if(btn.state != Button.States.pressed) {
                        btn.onPress(&btns[i]);
                    } else {
                        btn.onPressed(&btns[i]);
                    }
                } else {
                    bFn[btn.onHover](&btns[i]);
                }
            } else {
                if(btn.state == Button.States.pressed) {
                    btn.onRelease(&btns[i]);
                }
                bFn[btn.onIdle](&btns[i]);
            }
        } else {
            break;
        }
    }
}

inline fn input() void {
    const gamepad1 = w4.GAMEPAD1.*;
    //     const just_pressed1: u8 = @bitCast(u8, gamepad1) & (@bitCast(u8, gamepad1) ^ prev_state1);
    //     if(just_pressed1 & w4.
    //     if(gamepad1.button_down and (just_pressed1 == 0)) {
    //         w4.DRAW_COLORS.* = 0x4;
    //         w4.trace("down",.{});
    //         time = 0;
    //     }
    //     prev_state1 = @bitCast(u8,gamepad1);
    if (gamepad1.button_up) {
        snake.up();
        //         w4.trace("up", .{});
    }
    if (gamepad1.button_down) {
        snake.down();
        //         w4.trace("down", .{});
    }
    if (gamepad1.button_left) {
        snake.left();
        //         w4.trace("left", .{});
    }
    if (gamepad1.button_right) {
        //         w4.trace("right", .{});
        //         time = 0;
        snake.right();
    }
    mpos = w4.Mouse.pos(w4.MOUSE.*);
}

fn example() void {
    //
    var a: i32 = 0;
    var b: i32 = 0;
    var c: i32 = 0;
    var d: i32 = 0;
    var s: [10]u8 = undefined;
    _ = d + s[0];
    a = std.rand.Isaac64.random();
    b = std.rand.Isaac64.random();
    c = a + b;
}

test "basic test" {
    try std.testing.expectEqual(10, 3 + 7);
}
