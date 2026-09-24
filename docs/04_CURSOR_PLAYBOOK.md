# Cursor Playbook — How to drive Cursor through this project

This is a copy-paste prompt kit. Cursor performs best on **one roadmap task per conversation** with the docs pinned as context.

## 0. One-time setup in Cursor
1. Open the repo root as the workspace (the folder containing `project.godot`).
2. `.cursorrules` is picked up automatically. Verify with: *"What are the rules for autoloads in this project?"*
3. Add `docs/` to Cursor's indexed folders. In Composer/Agent, `@docs/02_ARCHITECTURE.md` whenever you start a task.
4. Install the **godot-tools** VS Code extension so Cursor gets GDScript syntax and LSP (run Godot editor in background; LSP on port 6005).
5. Keep the Godot editor open beside Cursor. Cursor writes; you press F5.

## 1. Kick-off prompt (start of every task)

```
@docs/02_ARCHITECTURE.md @docs/03_ROADMAP.md
Task: <ID> — <task title>.
Done when: <paste the "Done when" cell>.
Before coding: restate the task, list files to create/modify, and any GDD sections you'll rely on. Then implement. End with in-editor verification steps.
```

## 2. Example — Phase 2 kick-off (the risky one)

```
@docs/01_GDD.md @docs/02_ARCHITECTURE.md
Task: P2-01 — EventBus.noise_emitted + NoiseEmitterComponent.
Done when: GUT unit test on multiplier math passes.
Context: noise radius = base_radius * surface_mult * weight_mult * skill_noise_mult (see GDD §5.1, §5.3, ARCH §5). Weight mult: +1m per 5kg over 15kg is additive, apply after multiplication. Put the pure function in scripts/components/noise_math.gd so it's testable without a scene tree.
```

## 3. Review prompt (after Cursor finishes)

```
Review the diff you just made against .cursorrules and docs/02_ARCHITECTURE.md. List any violations (untyped vars, hardcoded numbers, cross-scene get_node, missing doc comment, missing tests). Fix them.
```

## 4. Bug prompt

```
Bug: <what happens>. Expected: <what should happen>. Repro: <scene, keys>.
Relevant files: @<path> @<path>
Find the root cause first and explain it in 3 lines before proposing a fix. Prefer the smallest change.
```

## 5. Tuning prompt

```
Expose every constant in @<script> as an @export or move it into @data/<resource>.tres. Do not change current values. List what moved.
```

## 6. Level blockout prompt (Phase 7)

Cursor can write `.tscn` files directly. It's effective for repetitive greybox geometry:

```
Generate scenes/world/district/zones/residential.tscn as a greybox using CSGBox3D nodes with materials from assets/materials/. Layout from docs/media/district_plan.png description: <describe in text: block sizes, street widths, building footprints, a courtyard, two fire escapes as gb_climb stairs, 6 IntelPickup placeholders at listed positions>. Put everything under a Node3D named Residential. Add a NavigationRegion3D with a NavigationMesh (cell size 0.25, agent radius 0.4, agent height 1.8) but do not bake — I will bake in-editor.
```

## 7. Things Cursor is bad at (do these yourself)
- Baking navmeshes, lightmaps — press the button in-editor.
- Judging "feel" — you play, you decide, then tell Cursor which numbers to change.
- Editing `.tscn` files with large binary-ish resources (embedded meshes). Keep scenes text-only and lean.
- Signal connections made in the editor inspector are stored in `.tscn`; Cursor may miss them. **Prefer connecting signals in code** (`_ready()`), so Cursor can see everything.

## 8. Session hygiene
- One task → one commit → one short note in `docs/DEVLOG.md` (date, task ID, what you learned, next).
- If Cursor produces > 400 lines in one go, stop and ask it to split into steps.
- When Cursor "can't find" a node, it's usually a scene-path assumption. Point it to the `.tscn`.
- Regenerate the debug GIF at each gate. Motivation matters more than velocity for a solo dev.
