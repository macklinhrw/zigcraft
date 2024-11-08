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
    model: rl.Model,  // Add model field
    data: []u8, // Block data for the chunk
    is_mesh_dirty: bool,  // Track if mesh needs updating

    pub fn create(allocator: *std.mem.Allocator, world: *World, position: rl.Vector3) !Chunk {
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

        var chunk = Chunk{
            .world = world,
            .position = position,
            .mesh = undefined,
            .model = undefined,
            .data = data,
            .is_mesh_dirty = true,
        };
        
        try chunk.generateMesh();
        return chunk;
    }

    pub fn destroy(self: @This(), allocator: *std.mem.Allocator) void {
        rl.unloadModel(self.model);
        allocator.free(self.mesh.vertices);
        allocator.free(self.mesh.indices);
        allocator.free(self.data);
    }

    pub fn render(self: @This()) void {
        if (self.is_mesh_dirty) {
            self.generateMesh() catch unreachable;
        }

        const position = rl.Vector3{
            .x = self.position.x * @as(f32, chunk_size_x),
            .y = self.position.y * @as(f32, chunk_size_y),
            .z = self.position.z * @as(f32, chunk_size_z),
        };

        rl.drawModel(self.model, position, 1.0, rl.Color.white);
    }
    pub fn generateMesh(self: *Chunk) !void {
        var vertices = std.ArrayList(f32).init(self.world.allocator.*);
        defer vertices.deinit();
        
        var indices = std.ArrayList(u16).init(self.world.allocator.*);
        defer indices.deinit();

        // Loop through all blocks
        for (0..chunk_size_x) |x| {
            for (0..chunk_size_y) |y| {
                for (0..chunk_size_z) |z| {
                    const index = x + y * chunk_size_x + z * chunk_size_x * chunk_size_y;
                    const block = self.data[index];

                    if (block == 0) continue; // Skip air blocks

                    // Check each face
                    try self.addFaceIfVisible(x, y, z, block, &vertices, &indices);
                }
            }
        }

        // Create the mesh
        self.mesh = rl.Mesh{
            .vertexCount = @intCast(vertices.items.len / 3),
            .triangleCount = @intCast(indices.items.len / 3),
            .vertices = try self.world.allocator.dupe(f32, vertices.items),
            .indices = try self.world.allocator.dupe(u16, indices.items),
            .texcoords = &[_]f32{},
            .texcoords2 = &[_]f32{},
            .normals = &[_]f32{},
            .colors = &[_]u8{},
            .tangents = &[_]f32{},
            .animVertices = &[_]f32{},
            .animNormals = &[_]f32{},
            .boneIds = &[_]u8{},
            .boneWeights = &[_]f32{},
            .vaoId = 0,
            .vboId = &[_]u32{},
        };

        self.model = rl.loadModelFromMesh(self.mesh);
        self.is_mesh_dirty = false;
    }

    fn addFaceIfVisible(self: *Chunk, x: usize, y: usize, z: usize, block: u8, vertices: *std.ArrayList(f32), indices: *std.ArrayList(u16)) !void {
        const faces = [_]struct { dx: i32, dy: i32, dz: i32 }{
            .{ .dx = 1, .dy = 0, .dz = 0 },  // right
            .{ .dx = -1, .dy = 0, .dz = 0 }, // left
            .{ .dx = 0, .dy = 1, .dz = 0 },  // top
            .{ .dx = 0, .dy = -1, .dz = 0 }, // bottom
            .{ .dx = 0, .dy = 0, .dz = 1 },  // front
            .{ .dx = 0, .dy = 0, .dz = -1 }, // back
        };

        for (faces) |face| {
            const nx = @as(i32, @intCast(x)) + face.dx;
            const ny = @as(i32, @intCast(y)) + face.dy;
            const nz = @as(i32, @intCast(z)) + face.dz;

            if (!self.isBlockVisible(nx, ny, nz)) {
                const base_index = @as(u16, @intCast(vertices.items.len / 3));
                try self.addFaceVertices(x, y, z, face.dx, face.dy, face.dz, vertices);
                try self.addFaceIndices(base_index, indices);
            }
        }
    }

    fn isBlockVisible(self: *Chunk, x: i32, y: i32, z: i32) bool {
        if (x < 0 or y < 0 or z < 0 or 
            x >= chunk_size_x or y >= chunk_size_y or z >= chunk_size_z) {
            return false;
        }

        const index = @as(usize, @intCast(x + y * chunk_size_x + z * chunk_size_x * chunk_size_y));
        return self.data[index] == 0;
    }

    fn addFaceVertices(self: *Chunk, x: usize, y: usize, z: usize, dx: i32, dy: i32, dz: i32, vertices: *std.ArrayList(f32)) !void {
        const fx = @as(f32, @floatFromInt(x));
        const fy = @as(f32, @floatFromInt(y));
        const fz = @as(f32, @floatFromInt(z));

        // Add the four vertices for the face
        if (dx != 0) {
            try vertices.appendSlice(&[_]f32{
                fx + @as(f32, @floatFromInt(dx)), fy, fz,
                fx + @as(f32, @floatFromInt(dx)), fy + 1, fz,
                fx + @as(f32, @floatFromInt(dx)), fy + 1, fz + 1,
                fx + @as(f32, @floatFromInt(dx)), fy, fz + 1,
            });
        } else if (dy != 0) {
            try vertices.appendSlice(&[_]f32{
                fx, fy + @as(f32, @floatFromInt(dy)), fz,
                fx + 1, fy + @as(f32, @floatFromInt(dy)), fz,
                fx + 1, fy + @as(f32, @floatFromInt(dy)), fz + 1,
                fx, fy + @as(f32, @floatFromInt(dy)), fz + 1,
            });
        } else {
            try vertices.appendSlice(&[_]f32{
                fx, fy, fz + @as(f32, @floatFromInt(dz)),
                fx + 1, fy, fz + @as(f32, @floatFromInt(dz)),
                fx + 1, fy + 1, fz + @as(f32, @floatFromInt(dz)),
                fx, fy + 1, fz + @as(f32, @floatFromInt(dz)),
            });
        }
    }

    fn addFaceIndices(self: *Chunk, base_index: u16, indices: *std.ArrayList(u16)) !void {
        try indices.appendSlice(&[_]u16{
            base_index, base_index + 1, base_index + 2,
            base_index, base_index + 2, base_index + 3,
        });
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
