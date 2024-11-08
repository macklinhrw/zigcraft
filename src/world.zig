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

        // Create initial chunks in a 2x2 grid around origin
        for (0..2) |x| {
            for (0..2) |z| {
                const chunk = try Chunk.create(allocator, &world, rl.Vector3.init(@as(f32, @floatFromInt(x)) - 1.0, // Center around origin
                    0.0, // At ground level
                    @as(f32, @floatFromInt(z)) - 1.0 // Center around origin
                ));
                try world.chunks.append(chunk);
            }
        }

        return world;
    }

    pub fn render(self: *World) void {
        // Draw world origin for reference
        rl.drawCube(rl.Vector3.init(0.0, 0.0, 0.0), 2.0, 2.0, 2.0, rl.Color.red);
        rl.drawGrid(100, 1.0);

        for (self.chunks.items) |*chunk| {
            chunk.render();

            // Draw chunk bounds
            const pos = rl.Vector3{
                .x = chunk.position.x * @as(f32, @floatFromInt(32)),
                .y = chunk.position.y * @as(f32, @floatFromInt(32)),
                .z = chunk.position.z * @as(f32, @floatFromInt(32)),
            };
            rl.drawCubeWires(pos, 32.0, 32.0, 32.0, rl.Color.yellow);
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
