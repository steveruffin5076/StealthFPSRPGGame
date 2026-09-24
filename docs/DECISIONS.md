# Architecture Decision Log

Record any deviation from docs/02_ARCHITECTURE.md here. Newest first.

| Date | ID | Decision | Why | Consequences |
|---|---|---|---|---|
| 2026-09-24 | ADR-001 | Godot 4 + GDScript, greybox-first, hitscan ballistics for slice | Solo dev, 1–3 month slice, Cursor authoring friendliness | Projectile sim & final art deferred to backlog |
| 2026-09-24 | ADR-002 | Single `EventBus.noise_emitted` signal is the only detection audio channel | Enables faction-vs-faction luring & one visualizer for tuning | `AudioManager` must wrap all 3D SFX |
| 2026-09-24 | ADR-003 | Loot lost on death; Secure Pouch 2×2 keeps intel; 1-sortie corpse recovery | Extraction tension (GDD pillar "Return or lose it") | Needs `PlayerCorpse` persistence in save |
