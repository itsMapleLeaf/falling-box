# Project guidelines

This is a living record of project-specific design and implementation decisions.
Add future conventions and lessons here when they should guide later work.

## Editor and runtime parity

What appears in the running game should look as close as practical to what is
visible in the Godot editor. A scene should communicate its composition without
requiring the game to run.

- Prefer editor-visible nodes and resources for ordinary game visuals.
- Use `MeshInstance2D` with rectangle meshes for simple rectangular game shapes.
- Keep visual nodes beside their collision nodes so their alignment is easy to
  inspect in the editor.
- Prefer authored scene positions and dimensions over positioning the whole scene
  procedurally at startup.
- Reserve `_draw()` for genuinely procedural visuals, temporary debugging, or
  cases where it has a clear measured advantage. Do not use it as the default
  way to assemble ordinary scene art.

## Current project structure

- Keep scenes, scripts, and tests together in the flat `src/` directory while
  the project remains small.
- Keep shared tuning values in `src/game_config.gd` rather than scattering magic
  numbers through gameplay scripts.

## Node references

- Prefer typed exported node references, assigned in the scene inspector, over
  `@onready` variables that depend on hard-coded node paths.
- Exported references are more flexible when nodes move or are renamed and make
  a script's scene dependencies visible in the editor.
- Use `@onready` path lookups only when an exported reference would not be
  practical, such as nodes created or discovered dynamically at runtime.

## Verification

- Write automated gameplay tests with GUT. Keep test scripts in the flat `src/`
  directory with the `_test.gd` filename suffix.
- Changes to gameplay behavior should receive a small headless regression test
  when the behavior can be checked deterministically.
- Run the project through Godot after editing scenes or scripts so broken resource
  paths and parser errors are caught immediately.
