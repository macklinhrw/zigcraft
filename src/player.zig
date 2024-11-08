const std = @import("std");
const rl = @import("raylib");
const World = @import("world.zig").World;
const rlm = @import("raylib").math;

// Define constants for the keys
const FORWARD_KEY = rl.KeyboardKey.key_w;
const BACKWARD_KEY = rl.KeyboardKey.key_s;
const LEFT_KEY = rl.KeyboardKey.key_a;
const RIGHT_KEY = rl.KeyboardKey.key_d;

pub const Player = struct {
    world: *World,
    camera: rl.Camera3D, // Camera is used for player's view

    // Position
    block_position: rl.Vector3,
    chunk_offset: rl.Vector3,

    // Player rotation
    yaw: f32, // Rotation around the Y-axis
    pitch: f32, // Rotation around the X-axis

    // Constructor function to create a new Player
    pub fn create(world: *World, position: rl.Vector3) Player {
        const eye_height = 1.8; // Player's eye height
        return Player{
            .world = world,
            .camera = rl.Camera3D{
                .position = rlm.vector3Add(position, rl.Vector3.init(0.0, eye_height, 0.0)),
                .target = position,
                .up = rl.Vector3.init(0.0, 1.0, 0.0),
                .fovy = 60.0,
                .projection = rl.CameraProjection.camera_perspective,
            },
            .block_position = position,
            .chunk_offset = rl.Vector3.init(0.0, 0.0, 0.0),
            .yaw = std.math.pi, // Initial yaw facing forward
            .pitch = 0.0, // Level pitch
        };
    }

    pub fn update(self: *Player) void {
        const mouse_sensitivity = 0.003; // Adjust the sensitivity as needed
        const eye_height = 1.8;
        const max_pitch = std.math.degreesToRadians(89.0);

        // Get mouse movement delta
        const mouse_delta = rl.getMouseDelta();

        // Update yaw and pitch based on mouse movement
        self.yaw += -mouse_delta.x * mouse_sensitivity;
        self.pitch += -mouse_delta.y * mouse_sensitivity; // Invert Y-axis if needed

        // Limit the pitch to avoid flipping
        if (self.pitch > max_pitch) {
            self.pitch = max_pitch;
        } else if (self.pitch < -max_pitch) {
            self.pitch = -max_pitch;
        }

        // Wrap yaw to keep it within 0 to 2π
        const two_pi = std.math.pi * 2.0;
        if (self.yaw > two_pi) {
            self.yaw -= two_pi;
        } else if (self.yaw < 0.0) {
            self.yaw += two_pi;
        }

        // Calculate forward and right vectors based on yaw
        const forward = rl.Vector3.init(std.math.sin(self.yaw), 0.0, std.math.cos(self.yaw));
        const right = rl.Vector3.init(std.math.cos(self.yaw), 0.0, -std.math.sin(self.yaw));

        // Handle input for movement
        var movement = rl.Vector3.init(0.0, 0.0, 0.0);
        const speed: f32 = 0.1;

        if (rl.isKeyDown(FORWARD_KEY)) {
            movement = rlm.vector3Add(movement, forward);
        }
        if (rl.isKeyDown(BACKWARD_KEY)) {
            movement = rlm.vector3Subtract(movement, forward);
        }
        if (rl.isKeyDown(RIGHT_KEY)) {
            movement = rlm.vector3Subtract(movement, right);
        }
        if (rl.isKeyDown(LEFT_KEY)) {
            movement = rlm.vector3Add(movement, right);
        }

        // Normalize the movement vector
        if (movement.x != 0.0 or movement.z != 0.0) {
            movement = movement.normalize();

            // Apply speed
            movement = rlm.vector3Multiply(movement, rl.Vector3.init(speed, speed, speed));

            // Update the player's position
            self.block_position = rlm.vector3Add(self.block_position, movement);

            // Collision detection with the world (optional)
            // Implement collision detection logic here if needed
            // Example:
            // if (!self.world.isPassable(self.block_position)) {
            //     self.block_position -= movement;
            // }
        }

        // Update the camera position and target
        self.camera.position = rlm.vector3Add(self.block_position, rl.Vector3.init(0.0, eye_height, 0.0));

        // Calculate the direction the camera is facing based on yaw and pitch
        const direction = rl.Vector3.init(
            std.math.cos(self.pitch) * std.math.sin(self.yaw),
            std.math.sin(self.pitch),
            std.math.cos(self.pitch) * std.math.cos(self.yaw),
        );

        self.camera.target = rlm.vector3Add(self.camera.position, direction);
    }
};
