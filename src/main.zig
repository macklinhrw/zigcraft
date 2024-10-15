const std = @import("std");
const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

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

        rl.clearBackground(rl.Color.black);

        // Create a buffer to hold the formatted string.
        var buffer: [1024]u8 = undefined;

        // Format the string into the buffer and get the slice.
        const mouseCoordinatesString = try std.fmt.bufPrintZ(&buffer, "Mouse Coordinates: ({}, {})", .{ rl.getMouseX(), rl.getMouseY() });

        rl.drawText(mouseCoordinatesString, 190, 200, 20, rl.Color.white);
        //----------------------------------------------------------------------------------
    }
}
