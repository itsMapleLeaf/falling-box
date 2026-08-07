# That Falling Box Game

A persistent online multiplayer platformer where players dodge, grab, and throw
falling boxes.

## Open the project

The project targets Godot 4.7.1. Open `project.godot` in Godot, or run it from
the repository root:

```sh
godot --editor --path .
```

Run the current main scene with F6 or the project with F5.

## Project layout

All scenes, scripts, and tests live together in `src/` while the prototype is
small. We can introduce subdirectories later when the project benefits from
them.

Project-specific implementation conventions are recorded in
`docs/guidelines.md`.

The current scene is a scale preview for the 50 px world grid, 40 px player,
and 50 px boxes. The player can move with A/D or the arrow keys and double-jump
with W, Up, or Space.

GUT 9.7.1 is installed in `addons/gut`. Run the headless test suite with:

```sh
godot --debug --path . --script addons/gut/gut_cmdln.gd
```
