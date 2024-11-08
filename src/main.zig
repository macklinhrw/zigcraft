const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;
const Player = @import("player.zig").Player;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.disableCursor();
    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Create the world (ensure your World module has a create method)
    var allocator = std.heap.page_allocator;
    var world = World.create(&allocator) catch unreachable;
    defer world.destroy();

    // Create the player at the origin
    var player = Player.create(&world, rl.Vector3.init(0.0, 0.0, 0.0));

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------
        player.update();

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.sky_blue);

        rl.beginMode3D(player.camera);
        defer rl.endMode3D();

        world.render();
        // rl.drawCube(rl.Vector3.init(0.0, 0.0, 0.0), 1.0, 1.0, 1.0, rl.Color.red);

        // Create a buffer to hold the formatted string.
        // var buffer: [1024]u8 = undefined;
        // Format the string into the buffer and get the slice.
        // const mouseCoordinatesString = try std.fmt.bufPrintZ(&buffer, "Mouse Coordinates: ({}, {})", .{ rl.getMouseX(), rl.getMouseY() });
        // rl.drawText(mouseCoordinatesString, 190, 200, 20, rl.Color.white);
        //----------------------------------------------------------------------------------
        // rl.drawText("123", screenWidth - 200, screenHeight - 20, 10, rl.Color.gray);
        // rl.drawFPS(10, 10);
    }
}
