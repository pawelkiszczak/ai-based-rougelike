# Toolchain

- Engine: Godot 4.7.0-stable
- Renderer: Compatibility (OpenGL)
- Logical viewport: 640×360
- Default window: 1280×720 (2× scale)
- Target platforms for this iteration: Windows and Linux

## Verification

From the repository root:

```sh
godot --version
godot --headless --path game --editor --quit
```

The installed editor version must report `4.7.0.stable` before production work begins. Generated `.godot/` state and export output are intentionally ignored; `project.godot`, scenes, scripts, and source assets remain tracked.
