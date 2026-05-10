# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Spacequest is a landscape-only iPhone shoot 'em up built with Swift and SpriteKit. Source files (Swift, `.sks` particle effects, audio, fonts, image assets) live as a flat directory under `Spacequest/`. Vector source art is in `AssetSources/` (Inkscape/GIMP) and is not consumed at build time — exported PNGs in `Spacequest/Images.xcassets` are.

- iOS deployment target: 13.0
- Swift: 6.0 (app target), 5.7 (tests target)
- Device family: iPhone only (`TARGETED_DEVICE_FAMILY = 1`); orientations restricted to landscape
- Bundle identifier: `com.rolfelster.Spacequest`

## Build / run / test

There is no workspace, Package.swift, or Pods — everything goes through `Spacequest.xcodeproj` directly. Open in Xcode, or use `xcodebuild`:

```sh
# Build for simulator
xcodebuild -project Spacequest.xcodeproj -scheme Spacequest -destination 'platform=iOS Simulator,name=iPhone 15' build

# Run unit tests
xcodebuild -project Spacequest.xcodeproj -scheme Spacequest -destination 'platform=iOS Simulator,name=iPhone 15' test

# Run a single test
xcodebuild ... test -only-testing:SpacequestTests/SpacequestTests/testSpaceshipLifePoints
```

`SpacequestTests/SpacequestTests.swift` contains scaffolding for `GameScene` collision tests that is intentionally non-executing (the assertions are commented out because `SKPhysicsContact` has no public initializer). Don't take that file as a model for new tests — write tests against types that can be constructed directly (`Spaceship`, `EnemySpaceship`, `ScoresNode`).

## Architecture

The app is a thin `UIKit` shell hosting a single `SKView`. There is no storyboard-driven navigation logic in code aside from the `Main` storyboard wiring an `SKView` into `GameViewController`.

**Scene flow** is owned by [GameViewController.swift](Spacequest/GameViewController.swift), which presents one `SKScene` at a time and acts as the delegate for all of them:

- `GameScene` — gameplay. Pauses itself when another scene is shown on top; `isPaused` toggling stops/restarts the enemy spawn `Timer`.
- `MainMenuScene` (subclass of `MenuScene`) — pause overlay with Resume / Restart / Info buttons.
- `GameOverScene` — shown when the player runs out of life points.

Scene → controller communication is via per-scene delegate protocols (`GameDelegate`, `MainMenuSceneDelegate`, `GameOverSceneDelegate`). Each scene holds a `weak` reference to its delegate. When adding a new scene, follow the same pattern rather than introducing a coordinator or notification-based flow.

**Game loop in `GameScene`** ([Spacequest/GameScene.swift](Spacequest/GameScene.swift)):

- Enemies are spawned by a recursively re-scheduled non-repeating `Timer` (`scheduleEnemySpaceshipSpawn` → `spawnEnemyTimerFireMethod` → schedules the next one). Pausing the scene invalidates the timer; un-pausing restarts the chain. Don't switch this to `repeats: true` — the random per-spawn interval depends on it being re-scheduled each tick.
- Physics gravity is zeroed; `GameScene` is its own `SKPhysicsContactDelegate`. Collision dispatch uses `CategoryBitmask` (raw `UInt32` bit flags in [Constants.swift](Spacequest/Constants.swift)) → `CollisionType` enum → typed `handleCollision(between:and:)` overloads. The generic `getNodes(from:typeA:typeB:)` helper handles bodyA/bodyB ordering, so contact handlers don't need to.
- HUD (`Joystick`, fire `Button`, menu `Button`, `LifeIndicator`, `ScoresNode`) is added directly as scene children with hand-positioned coordinates relative to `frame`. There is no auto-layout equivalent — adding a new HUD element means picking margins in `GameScene.Constants` and computing positions in a `configure…` method called from `configureHUD()`.

**Spaceship hierarchy**: `Spaceship: SKSpriteNode` ([Spacequest/Spaceship.swift](Spacequest/Spaceship.swift)) conforms to `LifePointsProtocol`. The base class fires `didRunOutOfLifePointsEventHandler` from `lifePoints`'s `didSet` whenever life drops to ≤ 0 — `GameScene` uses this hook (not collision code) to trigger destruction/explosion and the player-loss flow. Subclasses (`PlayerSpaceship`, `EnemySpaceship`) configure their own physics bodies and category bitmasks.

**Constants convention**: Cross-cutting enums (`ImageName`, `FontName`, `SoundName`, `CategoryBitmask`, `CollisionType`, `ScoreValue`, `LifePointsValue`) live in [Constants.swift](Spacequest/Constants.swift). Per-scene tuning values live in a `private struct Constants` inside the scene file. Honor this split when adding new values — the README explicitly calls out spread-out constants as a known pain point, so prefer extending the existing enums over adding parallel ones.

**Singletons**: `MusicManager.shared` (background music) and `AnalyticsManager.sharedInstance` (currently a no-op stub). The analytics calls are intentionally empty — leave them as tracking hook points.

**Bridging header** ([Spacequest/Spacequest-Bridging-Header.h](Spacequest/Spacequest-Bridging-Header.h)) exists but is empty; there is no Objective-C code in the project today.
