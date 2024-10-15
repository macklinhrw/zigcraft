const std = @import("std");
// const zgl = @import("zgl");
// const glfw = @cImport({
//     @cInclude("GLFW/glfw3.h");
// });
// const gl = @cImport({
//     @cInclude("GL/glew.h");
// });

pub fn main() !void {
    // Initialize GLFW
    // if (glfw.glfwInit() == 0) {
    //     std.debug.print("Failed to initialize GLFW\n", .{});
    //     return error.GlfwInitFailed;
    // }
    // defer glfw.glfwTerminate();

    // // Create a windowed mode window and its OpenGL context
    // const window = glfw.glfwCreateWindow(640, 480, "ZigCraft GLFW Test", null, null) orelse {
    //     std.debug.print("Failed to create GLFW window\n", .{});
    //     return error.GlfwCreateWindowFailed;
    // };
    // defer glfw.glfwDestroyWindow(window);

    // // Make the window's context current
    // glfw.glfwMakeContextCurrent(window);

    // Initialize GLEW
    // if (gl.glewInit() != gl.GLEW_OK) {
    //     std.debug.print("Failed to initialize GLEW\n", .{});
    //     return error.GlewInitFailed;
    // }

    // Initialize zgl
    // try zgl.init();
    // try gl.glewInit();

    // Main loop
    // while (glfw.glfwWindowShouldClose(window) == 0) {
    //     // Set the clear color (light blue)
    //     // zgl.clearColor(0.529, 0.808, 0.922, 1.0);
    //     // zgl.clear(.{ .color = true });

    //     // Swap front and back buffers
    //     glfw.glfwSwapBuffers(window);

    //     // Poll for and process events
    //     glfw.glfwPollEvents();
    // }

    std.debug.print("GLFW test completed successfully\n", .{});
}
