Download Learn News Zig Software Foundation Devlog Source Join a Community
← Back to Learn
Samples
Calling external library functions
Memory leak detection
C interoperability
Zigg Zagg
Generic Types
Using cURL from Zig
Calling external library functions
All system API functions can be invoked this way, you do not need library bindings to interface them.

0-windows-msgbox.zig
const win = @import("std").os.windows;

extern "user32" fn MessageBoxA(?win.HWND, [*:0]const u8, [*:0]const u8, u32) callconv(win.WINAPI) i32;

pub fn main() !void {
\_ = MessageBoxA(null, "world!", "Hello", 0);
}
Shell
$ zig test 0-windows-msgbox.zig
All 0 tests passed.
Memory leak detection
Using std.heap.GeneralPurposeAllocator you can track double frees and memory leaks.

1-memory-leak.zig
const std = @import("std");

pub fn main() !void {
var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
defer std.debug.assert(general_purpose_allocator.deinit() == .ok);

    const gpa = general_purpose_allocator.allocator();

    const u32_ptr = try gpa.create(u32);
    _ = u32_ptr; // silences unused variable error

    // oops I forgot to free!

}
Shell
$ zig build-exe 1-memory-leak.zig
$ ./1-memory-leak
error(gpa): memory address 0x7f0b7aaa5000 leaked:
/home/ci/actions-runner-website/\_work/www.ziglang.org/www.ziglang.org/assets/zig-code/samples/1-memory-leak.zig:9:35: 0x10378f0 in main (1-memory-leak)
const u32_ptr = try gpa.create(u32);
^
/home/ci/deps/zig-linux-x86_64-0.13.0/lib/std/start.zig:524:37: 0x10377d5 in posixCallMainAndExit (1-memory-leak)
const result = root.main() catch |err| {
^
/home/ci/deps/zig-linux-x86_64-0.13.0/lib/std/start.zig:266:5: 0x10372f1 in \_start (1-memory-leak)
asm volatile (switch (native_arch) {
^

thread 3029432 panic: reached unreachable code
/home/ci/deps/zig-linux-x86_64-0.13.0/lib/std/debug.zig:412:14: 0x1037b5d in assert (1-memory-leak)
if (!ok) unreachable; // assertion failure
^
/home/ci/actions-runner-website/\_work/www.ziglang.org/www.ziglang.org/assets/zig-code/samples/1-memory-leak.zig:5:27: 0x1037952 in main (1-memory-leak)
defer std.debug.assert(general_purpose_allocator.deinit() == .ok);
^
/home/ci/deps/zig-linux-x86_64-0.13.0/lib/std/start.zig:524:37: 0x10377d5 in posixCallMainAndExit (1-memory-leak)
const result = root.main() catch |err| {
^
/home/ci/deps/zig-linux-x86_64-0.13.0/lib/std/start.zig:266:5: 0x10372f1 in \_start (1-memory-leak)
asm volatile (switch (native_arch) {
^
???:?:?: 0x0 in ??? (???)
(process terminated by signal)
C interoperability
Example of importing a C header file and linking to both libc and raylib.

2-c-interop.zig
// build with `zig build-exe cimport.zig -lc -lraylib`
const ray = @cImport({
@cInclude("raylib.h");
});

pub fn main() void {
const screenWidth = 800;
const screenHeight = 450;

    ray.InitWindow(screenWidth, screenHeight, "raylib [core] example - basic window");
    defer ray.CloseWindow();

    ray.SetTargetFPS(60);

    while (!ray.WindowShouldClose()) {
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Hello, World!", 190, 200, 20, ray.LIGHTGRAY);
    }

}
Zigg Zagg
Zig is optimized for coding interviews (not really).

3-ziggzagg.zig
const std = @import("std");

pub fn main() !void {
const stdout = std.io.getStdOut().writer();
var i: usize = 1;
while (i <= 16) : (i += 1) {
if (i % 15 == 0) {
try stdout.writeAll("ZiggZagg\n");
} else if (i % 3 == 0) {
try stdout.writeAll("Zigg\n");
} else if (i % 5 == 0) {
try stdout.writeAll("Zagg\n");
} else {
try stdout.print("{d}\n", .{i});
}
}
}
Shell
$ zig build-exe 3-ziggzagg.zig
$ ./3-ziggzagg
1
2
Zigg
4
Zagg
Zigg
7
8
Zigg
Zagg
11
Zigg
13
14
ZiggZagg
16
Generic Types
In Zig types are comptime values and we use functions that return a type to implement generic algorithms and data structures. In this example we implement a simple generic queue and test its behaviour.

4-generic-type.zig
const std = @import("std");

pub fn Queue(comptime Child: type) type {
return struct {
const This = @This();
const Node = struct {
data: Child,
next: ?*Node,
};
gpa: std.mem.Allocator,
start: ?*Node,
end: ?\*Node,

        pub fn init(gpa: std.mem.Allocator) This {
            return This{
                .gpa = gpa,
                .start = null,
                .end = null,
            };
        }
        pub fn enqueue(this: *This, value: Child) !void {
            const node = try this.gpa.create(Node);
            node.* = .{ .data = value, .next = null };
            if (this.end) |end| end.next = node //
            else this.start = node;
            this.end = node;
        }
        pub fn dequeue(this: *This) ?Child {
            const start = this.start orelse return null;
            defer this.gpa.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.data;
        }
    };

}

test "queue" {
var int_queue = Queue(i32).init(std.testing.allocator);

    try int_queue.enqueue(25);
    try int_queue.enqueue(50);
    try int_queue.enqueue(75);
    try int_queue.enqueue(100);

    try std.testing.expectEqual(int_queue.dequeue(), 25);
    try std.testing.expectEqual(int_queue.dequeue(), 50);
    try std.testing.expectEqual(int_queue.dequeue(), 75);
    try std.testing.expectEqual(int_queue.dequeue(), 100);
    try std.testing.expectEqual(int_queue.dequeue(), null);

    try int_queue.enqueue(5);
    try std.testing.expectEqual(int_queue.dequeue(), 5);
    try std.testing.expectEqual(int_queue.dequeue(), null);

}
Shell
$ zig test 4-generic-type.zig
1/1 4-generic-type.test.queue...OK
All 1 tests passed.
Using cURL from Zig
5-curl.zig
// compile with `zig build-exe zig-curl-test.zig --library curl --library c $(pkg-config --cflags libcurl)`
const std = @import("std");
const cURL = @cImport({
@cInclude("curl/curl.h");
});

pub fn main() !void {
var arena_state = std.heap.ArenaAllocator.init(std.heap.c_allocator);
defer arena_state.deinit();

    const allocator = arena_state.allocator();

    // global curl init, or fail
    if (cURL.curl_global_init(cURL.CURL_GLOBAL_ALL) != cURL.CURLE_OK)
        return error.CURLGlobalInitFailed;
    defer cURL.curl_global_cleanup();

    // curl easy handle init, or fail
    const handle = cURL.curl_easy_init() orelse return error.CURLHandleInitFailed;
    defer cURL.curl_easy_cleanup(handle);

    var response_buffer = std.ArrayList(u8).init(allocator);

    // superfluous when using an arena allocator, but
    // important if the allocator implementation changes
    defer response_buffer.deinit();

    // setup curl options
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_URL, "https://ziglang.org") != cURL.CURLE_OK)
        return error.CouldNotSetURL;

    // set write function callbacks
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_WRITEFUNCTION, writeToArrayListCallback) != cURL.CURLE_OK)
        return error.CouldNotSetWriteCallback;
    if (cURL.curl_easy_setopt(handle, cURL.CURLOPT_WRITEDATA, &response_buffer) != cURL.CURLE_OK)
        return error.CouldNotSetWriteCallback;

    // perform
    if (cURL.curl_easy_perform(handle) != cURL.CURLE_OK)
        return error.FailedToPerformRequest;

    std.log.info("Got response of {d} bytes", .{response_buffer.items.len});
    std.debug.print("{s}\n", .{response_buffer.items});

}

fn writeToArrayListCallback(data: *anyopaque, size: c_uint, nmemb: c_uint, user_data: *anyopaque) callconv(.C) c_uint {
var buffer: _std.ArrayList(u8) = @alignCast(@ptrCast(user_data));
var typed_data: [_]u8 = @ptrCast(data);
buffer.appendSlice(typed_data[0 .. nmemb * size]) catch return 0;
return nmemb \* size;
}
This page is also available in the following languages:
English (original) Italiano Deutsch Українська 日本語 中文
