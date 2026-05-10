# Spacequest Feature Roadmap

Forward-looking gameplay and content roadmap. Ordered so each phase lands a self-contained, shippable improvement and unblocks the next. Phases 1–4 are additive content; Phase 5 restructures the game loop and depends on the earlier work.

---

## Phase 1 — Settings screen with audio controls

Goal: a dedicated `SettingsScene` reachable from the main menu where the player can mute and adjust music (and SFX) volume, persisted across launches.

- Add a `SettingsScene: MenuScene` with controls:
  - Music: on/off toggle + volume slider (0.0–1.0)
  - SFX: on/off toggle + volume slider (deferred if SFX volume isn't already routed through a single point)
  - Back button
- Slider control: SpriteKit has no slider — build a minimal `Slider: SKNode` (track + draggable thumb, `valueChanged` closure) following the existing `Joystick`/`Button` pattern. Keep it in its own file alongside `Joystick.swift`.
- Persistence: introduce `SettingsStore` wrapping `UserDefaults` with typed keys (`musicVolume`, `musicEnabled`, `sfxVolume`, `sfxEnabled`). Single source of truth — no scattered `UserDefaults.standard` reads.
- Wire `MusicManager.shared` to read from `SettingsStore` on init and expose `setVolume(_:)` / `setEnabled(_:)` that update the live `AVAudioPlayer`. Apply changes immediately while the slider is dragged so the player gets feedback.
- Add a "Settings" button to `MainMenuScene` (the pause overlay) and to the title menu. Follow the existing `MainMenuSceneDelegate` pattern: `didTapSettingsButton(in:)` → `GameViewController` presents `SettingsScene`, dismisses back to whatever was underneath.
- Audio-route consideration: respect the iOS silent switch and interruptions (phone call). If `MusicManager` doesn't already configure `AVAudioSession`, do it here — `.ambient` category is the right default for a game that yields to other audio.

Acceptance: muting in Settings silences music immediately; relaunching the app preserves the choice; pausing → Settings → Resume returns to the same gameplay state.

---

## Phase 2 — More enemy spaceship types

Goal: replace the single `EnemySpaceship` with a small bestiary that varies movement, durability, and fire behavior.

- Refactor `EnemySpaceship` into a base class (or protocol-driven configuration) that owns the shared physics body, category bitmask, and `LifePointsProtocol` plumbing. Keep the `didRunOutOfLifePointsEventHandler` contract intact — `GameScene` already depends on it.
- Introduce concrete types, each in its own file:
  - **Scout** — current behavior: straight left, low HP, no fire. Baseline.
  - **Gunner** — straight left, fires aimed bullets at the player on a timer.
  - **Weaver** — sinusoidal Y-axis motion via `SKAction.customAction` or a `SKAction.sequence` of `moveBy`s, medium HP.
  - **Bomber** — slow, high HP, drops downward projectiles at intervals.
  - **Kamikaze** — accelerates toward the player's last known position; high collision damage, fragile.
- Spawn weighting: replace the single `spawnEnemySpaceship()` in `GameScene` with a weighted picker. Add `EnemySpawnTable` keyed by difficulty (a single `level: Int` for now; Phase 5 expands this). Keep the recursive non-repeating `Timer` chain — the CLAUDE.md note about per-spawn random intervals still applies.
- Constants: add `EnemyType` enum to [Constants.swift](Spacequest/Constants.swift) alongside `CategoryBitmask`. Per-enemy tuning (HP, speed, fire rate, score value) lives on the type itself, not in `GameScene.Constants` — gameplay tuning that varies per entity doesn't belong in the scene's struct.
- Score: extend `ScoreValue` with one entry per enemy type so kills award appropriately.
- Art: each enemy needs at least one sprite. Add to `Spacequest/Images.xcassets` with `enemy_<type>` naming; export from `AssetSources/`. Until art lands, ship with palette-swapped tints of the existing sprite so the mechanics can be tested.

Acceptance: each enemy type is visibly distinct in motion, fires appropriately (or doesn't), and contributes to score with a balanced spawn distribution at level 1.

---

## Phase 3 — New weapons for the player

Goal: expand the player from a single forward bullet to a small weapon set, with a clean swap mechanism that Phase 4 (pickups) can drive.

- Define a `Weapon` protocol: `fire(from spaceship: PlayerSpaceship, in scene: SKScene)`, `cooldown: TimeInterval`, `iconName: String`. Concrete weapons:
  - **Pulse** (default) — current single forward bullet.
  - **Spread** — three bullets at -15°/0°/+15°.
  - **Laser** — short-lived `SKShapeNode` beam + brief invincibility-frame on overlap, instead of a projectile node.
  - **Missile** — slow homing projectile that picks the nearest live enemy each `update(_:)` tick.
  - **Plasma** — high-damage slow projectile with a larger physics body.
- Refactor `PlayerSpaceship` to hold a `currentWeapon: Weapon` and route the existing fire-button tap through it. The fire `Button` keeps the same delegate signature; only the handler changes.
- Cooldown handling: track `lastFiredAt: TimeInterval` per weapon and gate firing in the scene's `update(_:)` rather than via `Timer` — the game loop already runs there and pauses cleanly with the scene.
- Bullet/projectile category bitmasks: add per-weapon flags in [Constants.swift](Spacequest/Constants.swift) so collision dispatch in `GameScene.handleCollision` can apply weapon-specific damage. Keep the typed `handleCollision(between:and:)` overload pattern — add new overloads, don't widen existing ones.
- HUD: small weapon icon + remaining-ammo counter (for limited-ammo weapons from Phase 4) near the fire button. Position via a new `Constants.weaponIndicator…Margin` entry, configured in a `configureWeaponIndicator()` called from `configureHUD()`.

Acceptance: each weapon feels distinct in fire rate, spread, and on-hit behavior; switching weapons (programmatically for now) updates the HUD icon immediately.

---

## Phase 4 — Pickup crates with special weapons

Goal: enemies and/or the world drop crates that grant a temporary special weapon or ammo.

- New `Pickup: SKSpriteNode` with subtypes: `WeaponPickup(weapon: Weapon, ammo: Int)`, `LifePickup(amount: Int)`, `ShieldPickup(duration: TimeInterval)`.
- Spawn rules:
  - Random chance on enemy destruction (per-enemy-type drop table — bombers drop more often than scouts).
  - Independent timed spawn from the right edge that drifts left at a slow speed, similar to enemies but on a separate timer chain.
- Collision: add `pickup` to `CategoryBitmask` and a `CollisionType.playerPickup` case. New `handleCollision(between: PlayerSpaceship, and: Pickup)` overload applies the effect and removes the crate.
- Weapon pickup behavior: swaps `playerSpaceship.currentWeapon` to the granted weapon with a finite ammo count or duration. When ammo hits zero (or the timer elapses), revert to Pulse. The HUD weapon indicator from Phase 3 already reflects this.
- Visual feedback: pickup spawn plays a faint pulse animation; pickup collected plays a brief scale/fade and an SFX (`SoundName.pickup`). Add particle file `Pickup.sks` if budget allows; otherwise reuse an existing emitter tinted differently.
- Art: one sprite per pickup type in `Images.xcassets`; iconography on the crate suggests the contents (lightning = laser, missile silhouette = missile, etc.).

Acceptance: killing a bomber sometimes drops a crate; flying over it grants the weapon with on-screen ammo; ammo depletes correctly and reverts to Pulse.

---

## Phase 5 — Levels, bosses, and progression

Goal: turn the endless wave into a structured run. This is the largest phase and depends on Phases 2–4 existing.

### 5a. Level structure

- Introduce `Level` as a value type describing: ID, display name, duration (or kill quota), `EnemySpawnTable`, background variant, music track, optional boss reference.
- `LevelManager` (singleton or scene-owned) tracks current level index, progress within the level, and triggers transitions. Keep it independent of `GameScene` so it survives scene transitions.
- Level transition flow: when level criteria met → stop spawning regular enemies → trigger boss (if any) → on boss death, present a "Level N Complete" overlay → load next level into the existing `GameScene` (don't tear down the scene; swap configuration).
- Background variant: extend `ImageName` with per-level background assets. The Phase 1 scrolling background work makes parallax variants per level cheap.

### 5b. Bosses

- `Boss: Spaceship` base class with multi-phase HP (e.g., HP brackets that change attack pattern). Each phase swaps the active `WeaponPattern` (a small object that schedules projectile spawns).
- One boss per level (start with 3 levels = 3 bosses). Each boss is a separate file/class encoding its movement and attack patterns — don't try to data-drive bosses too early; their behavior is too varied.
- Boss HP bar pinned to the top of the screen during boss fights; appears/disappears with the encounter. New HUD element following the existing `LifeIndicator` pattern.
- Defeating a boss guarantees a weapon pickup drop (ties to Phase 4).

### 5c. Difficulty curve

- Per-level spawn tables shift weights toward harder enemy types as level index grows.
- Player carry-over: full life refill on level start (decision: revisit if testing shows it makes early levels trivial); carried weapon and ammo persist across levels.
- Score multiplier increases per level — small reward for reaching deeper levels.

### 5d. Persistence

- Save high score per level and an "unlocked levels" set in `SettingsStore` (extended from Phase 1). Title menu gains a level-select for unlocked levels; new players start at level 1.
- Game over from any level returns to the title screen; player can resume from the highest unlocked level.

Acceptance: a fresh install plays level 1 → boss → level 2 → boss → level 3 → boss → end-of-content screen, with persisted high scores and level unlocks across launches.

---

## Cross-cutting concerns

- **Constants discipline**: per CLAUDE.md, cross-cutting enums (`ImageName`, `SoundName`, `CategoryBitmask`, `CollisionType`, `ScoreValue`) extend the central [Constants.swift](Spacequest/Constants.swift); per-scene tuning stays in each scene's `private struct Constants`. Don't introduce parallel constants files.
- **Delegate pattern**: every new scene (`SettingsScene`, level-complete overlay, boss-intro overlay) gets its own `…SceneDelegate` protocol with weak back-reference to `GameViewController`. No coordinator, no notifications.
- **Pause behavior**: `GameScene` already invalidates the spawn `Timer` on pause and restarts the chain on resume. Any new timer-driven system (pickup spawns, boss attack patterns) must follow the same pattern — invalidate on `isPaused = true`, re-schedule on `false`. Prefer scene `update(_:)`-driven timing where possible to avoid the bookkeeping entirely.
- **Tests**: write unit tests against types that can be constructed directly — `Weapon` cooldown logic, `EnemySpawnTable` distribution, `LevelManager` progression, `SettingsStore` round-tripping. Skip anything that needs `SKPhysicsContact` (the `SpacequestTests.swift` scaffolding shows why).
- **Asset pipeline**: every new sprite needs a vector source under `AssetSources/` and 1x/2x PNG exports under `Images.xcassets`. Don't ship art that exists only as a PNG with no source.

---

## Suggested sequencing

| Phase | Estimate | Blocks |
|-------|----------|--------|
| 1 — Settings + audio control | 2–3 days | nothing |
| 2 — Enemy types | 4–6 days | nothing |
| 3 — Weapons | 4–6 days | nothing |
| 4 — Pickups | 2–3 days | Phase 3 (needs `Weapon` protocol) |
| 5 — Levels + bosses | 2–3 weeks | Phases 2, 3, 4 |

Phases 1, 2, and 3 are independent and can be parallelized or interleaved. Phase 4 requires Phase 3's `Weapon` abstraction. Phase 5 is the only phase that meaningfully restructures the game loop and should be tackled last.
