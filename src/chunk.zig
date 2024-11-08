const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;

const chunk_size_x: i32 = 32;
const chunk_size_y: i32 = 32;
const chunk_size_z: i32 = 32;

pub const Chunk = struct {
    world: *World,

    // Position in chunk coordinates as rl.Vector3
    position: rl.Vector3,

    mesh: rl.Mesh,
    data: []u8, // Block data for the chunk

    pub fn create(allocator: *std.mem.Allocator, world: *World, position: rl.Vector3) !Chunk {
        // Allocate memory for the chunk's data
        var data = try allocator.alloc(u8, chunk_size_x * chunk_size_y * chunk_size_z);

        // Fill the data with block values for testing
        for (0..chunk_size_x) |ix| {
            for (0..chunk_size_y) |iy| {
                for (0..chunk_size_z) |iz| {
                    const index = ix + iy * chunk_size_x + iz * chunk_size_x * chunk_size_y;

                    // Simple test: Create a flat ground layer of grass blocks at iy == 0
                    if (iy > chunk_size_y - 2) {
                        data[index] = 1; // Grass block
                    } else if (iy <= chunk_size_y - 2) {
                        data[index] = 2; // Dirt blocks below grass
                    } else {
                        data[index] = 0; // Air
                    }
                }
            }
        }

        return Chunk{
            .world = world, // Your world instance
            .position = position,
            .mesh = undefined, // Not used in this simple rendering
            .data = data,
        };
    }

    pub fn destroy(self: @This(), allocator: *std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn render(self: @This()) void {
        const block_size: f32 = 1.0; // Size of each block

        // Loop over each block in the chunk
        for (0..chunk_size_x) |ix| {
            for (0..chunk_size_y) |iy| {
                for (0..chunk_size_z) |iz| {
                    const index = ix + iy * chunk_size_x + iz * chunk_size_x * chunk_size_y;
                    const block = self.data[index];

                    // Skip air blocks
                    if (block == 0) {
                        continue;
                    }

                    // Compute the world position of the block

                    // The chunk's world position
                    const chunk_world_x = self.position.x * @as(f32, chunk_size_x) * block_size;
                    const chunk_world_y = self.position.y * @as(f32, chunk_size_y) * block_size;
                    const chunk_world_z = self.position.z * @as(f32, chunk_size_z) * block_size;

                    // Block's position within the chunk
                    const block_world_x = chunk_world_x + @as(f32, @floatFromInt(ix)) * block_size;
                    const block_world_y = chunk_world_y + @as(f32, @floatFromInt(iy)) * block_size;
                    const block_world_z = chunk_world_z + @as(f32, @floatFromInt(iz)) * block_size;

                    const position = rl.Vector3{
                        .x = block_world_x + block_size / 2.0,
                        .y = block_world_y + block_size / 2.0,
                        .z = block_world_z + block_size / 2.0,
                    };

                    // Choose a color based on the block value
                    const color = getColorForBlock(block);

                    // // Draw the cube
                    // rl.drawCube(position, block_size, block_size, block_size, color);
                    // Draw the solid cube
                    rl.drawCube(position, block_size, block_size, block_size, color);

                    // Set up the wireframe color with light opacity
                    const wire_color = rl.Color{
                        .r = 0,
                        .g = 0,
                        .b = 0,
                        .a = 64, // Semi-transparent black
                    };

                    // Draw the cube wires (borders)
                    rl.drawCubeWires(position, block_size, block_size, block_size, wire_color);
                }
            }
        }
    }
};

// Helper function to get a color based on block type
fn getColorForBlock(block: u8) rl.Color {
    // For simplicity, define some colors based on block value
    switch (block) {
        1 => return rl.Color.green, // Grass
        2 => return rl.Color.brown, // Dirt
        3 => return rl.Color.gray, // Stone
        else => return rl.Color.purple, // Default color
    }
}
