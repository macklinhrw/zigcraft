const std = @import("std");
const rl = @import("raylib");
const Chunk = @import("chunk.zig").Chunk;

pub const World = struct {
    allocator: *std.mem.Allocator,
    chunks: std.ArrayList(Chunk),
    chunk_origin: rl.Vector3,
    center_offset: rl.Vector3,

    pub fn create(allocator: *std.mem.Allocator) !World {
        const chunks = std.ArrayList(Chunk).init(allocator.*);

        var world = World{
            .allocator = allocator,
            .chunks = chunks,
            .chunk_origin = rl.Vector3.init(0.0, 0.0, 0.0),
            .center_offset = rl.Vector3.init(0.0, 0.0, 0.0),
        };

        // Create initial chunks
        var x: f32 = 0;
        var y: f32 = 0;
        while (x < 1) : (x += 1) {
            while (y < 1) : (y += 1) {
                const chunk = try Chunk.create(allocator, &world, rl.Vector3.init(x, -1, y));
                // Append the chunk to the world's chunks list
                try world.chunks.append(chunk);
            }
        }

        return world;
    }

    pub fn render(self: @This()) void {
        for (self.chunks.items) |chunk| {
            chunk.render();
        }
    }

    // Function to free allocated resources
    pub fn destroy(self: @This()) void {
        // Free each chunk's data
        for (self.chunks.items) |*chunk| {
            self.allocator.free(chunk.data);
            // If you have additional resources like meshes, free them here
        }
        // De-initialize the chunks ArrayList
        self.chunks.deinit();
    }
};
