//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const capy = @import("capy");

// This is required for your app to build to WebAssembly and other particular architectures
pub usingnamespace capy.cross_platform;

pub fn main() !void {
    try capy.init();

    var window = try capy.Window.init();
    try window.set(capy.column(.{ .spacing = 10 }, .{ // have 10px spacing between each column's element
        capy.row(.{ .spacing = 5 }, .{ // have 5px spacing between each row's element
            capy.button(.{ .label = "Save", .onclick = @ptrCast(&buttonClicked) }),
            capy.button(.{ .label = "Run", .onclick = @ptrCast(&buttonClicked) }),
        }),
        // 'expanded' means the widget will take all the space it can
        // in the parent container
        capy.expanded(capy.textArea(.{ .text = "Hello World!" })),
    }));

    window.setPreferredSize(800, 600);
    window.show();
    capy.runEventLoop();

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    //const stdout_file = std.io.getStdOut().writer();
    //var bw = std.io.bufferedWriter(stdout_file);
    //const stdout = bw.writer();

    //try stdout.print("Run `zig build test` to run the tests.\n", .{});

    //try bw.flush(); // Don't forget to flush!
}

fn buttonClicked(button: *capy.Button) !void {
    std.log.info("You clicked the button with text {s}", .{button.getLabel()});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const global = struct {
        fn testOne(input: []const u8) anyerror!void {
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(global.testOne, .{});
}
