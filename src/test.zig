const std = @import("std");
const expect = @import("std").testing.expect;
const curl = @import("curl");

const open_api_url = "https://openrouter.ai/api/v1/chat/completions";
const api_key = "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";
const model_name = "google/gemini-flash-1.5-8b";

pub fn main() anyerror!void {
    std.debug.print("Hello, world!\n", .{});
}

pub const Usage = struct {
    prompt_tokens: u64,
    completion_tokens: ?u64,
    total_tokens: u64,
};

pub const Choice = struct { index: usize, finish_reason: ?[]const u8, message: struct { role: []const u8, content: []const u8 } };

pub const Completion = struct {
    id: []const u8,
    object: []const u8,
    created: u64,
    model: []const u8,
    choices: []Choice,
    // Usage is not returned by the Completion endpoint when streamed.
    usage: Usage,
};

const Message = struct {
    role: []const u8,
    content: []const u8,
};

test "curl" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer if (gpa.deinit() != .ok) @panic("leak");
    const allocator = gpa.allocator();

    const bundle = try curl.allocCABundle(allocator);
    defer bundle.deinit();

    const easy = try curl.Easy.init(allocator, .{ .ca_bundle = bundle });
    defer easy.deinit();

    try easy.setVerbose(true);

    var headers = try curl.Easy.Headers.init(allocator);
    defer headers.deinit();

    const auth_header = try std.fmt.allocPrint(allocator, "Bearer {s}", .{api_key});
    defer allocator.free(auth_header);

    try headers.add("Authorization", auth_header);
    try headers.add("Content-Type", "application/json");
    try easy.setHeaders(headers);

    try easy.setMethod(.POST);

    const body_obj = .{ .model = model_name, .messages = &[_]Message{
        .{ .role = "system", .content = "You are a friendly Assistant." },
        .{ .role = "user", .content = "What is Zig?" },
    }, .stream = false };

    // Json Stringify the Body
    var buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buf);
    var body_string = std.ArrayList(u8).init(fba.allocator());
    try std.json.stringify(body_obj, .{}, body_string.writer());

    // std.debug.print("Body: {s}\n\n", .{body_string.items});

    try easy.setUrl(open_api_url);
    try easy.setPostFields(body_string.items);
    var writeBuf = curl.Buffer.init(allocator);
    try easy.setWritedata(&writeBuf);
    try easy.setWritefunction(curl.bufferWriteCallback);

    var resp = try easy.perform();
    resp.body = writeBuf;
    defer resp.deinit();

    // const parsed = try std.json.parseFromSlice(
    //     Completion,
    //     allocator,
    //     resp.body.?.items,
    //     .{ .ignore_unknown_fields = true },
    // );
    // defer parsed.deinit();

    // const place = parsed.value;
    // std.debug.print("response: {s}\n\n", .{place.choices[0].message.content});

    std.debug.print("Status code: {d}\nBody: {s}\n", .{
        resp.status_code,
        resp.body.?.items,
    });
}
