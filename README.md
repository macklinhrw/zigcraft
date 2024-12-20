# ZigCraft

## Prerequisites

- Install the correct version of Zig (see 'Versions' below), you can use zigup.

## Steps to Recreate

I used `zig fetch --save [url]` for adding dependencies properly (url is a link to an archive).

I needed to download the nominated version of zig manually. I downloaded the tar, unarchived it, then made a symbolic link to `/usr/local/bin/zig` pointing to the unarchived install location of the zig binary.

```
ln -s /path/to/unarchived/installation/zig /usr/local/bin/zig
```

To build and run: `zig build run`

## ZLS Issues

To get ZLS working I followed [this guide](https://ziggit.dev/t/zls-not-working-with-imported-raylib/3986/3).

Basically, I cloned the repo, changed my Zig version (using zigup), then created a symbolic link for the built executeable to `/usr/local/bin/zls`.

Then, I added the file path to my VSCode configuration.

## Versions

1. Zig `0.14.0-dev.1911+3bf89f55c` (same ZLS version)

## Versions (old)

1. [zigglgen](https://github.com/castholm/zigglgen/releases)

- `0.2.3`

2. [mach-glfw](https://github.com/slimsag/mach-glfw)

- commit: `fb4ae48540454270ab969c8c645bbc6eff3c2dfb`

3. nominated zig version `2024.5.0-mach`, `0.13.0-dev.351+64ef45eb0`

- [nominated zig docs](https://machengine.org/docs/nominated-zig/)

- downloaded directly: [macOS aarch64 (Apple Silicon)](zig-macos-aarch64-0.13.0-dev.351+64ef45eb0.tar.xz)

## References

[OpenGL Example Repo](https://github.com/slimsag/mach-glfw-opengl-example/tree/main)
