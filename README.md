# Stinky Rat

This repository holds two Godot 4.5 projects.

## `reference/`

The existing game, **Stinky Rat Reborn**, kept as a design reference. Open `reference/project.godot` in Godot 4.5. Nothing here has been ported forward yet.

## `final/`

Where the new version is built. It is an empty Godot 4.5 project (default Forward+ renderer, no main scene, no game logic). Open `final/project.godot` to start the rebuild.

## Repository files

`.gitignore`, `.gitattributes`, and `.editorconfig` stay at the repository root and apply to both projects. Godot cache folders (`.godot/` and `.import/`) are gitignored. Import metadata (`*.import`) that belongs to the reference assets lives with those assets under `reference/`.
