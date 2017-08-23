
enum ImageName: String {
    case PlayerSpaceship = "player_spaceship"
    case EnemySpaceship = "enemy_spaceship"
    case Missile = "player_missile"
    case LifeBall = "life_ball"
    case GameBackgroundPad = "game_background_ipad"
    case GameBackgroundPhone = "game_background_iphone"
    case MenuBackgroundPad = "menu_background_ipad"
    case MenuBackgroundPhone = "menu_background_iphone"
    case MenuButtonRestartNormal = "menu_button_restart_normal"
    case MenuButtonRestartSelected = "menu_button_restart_selected"
    case MenuButtonResumeNormal = "menu_button_resume_normal"
    case MenuButtonResumeSelected = "menu_button_resume_selected"
    case MenuButtonInfoNormal = "menu_button_info_normal"
    case MenuButtonInfoSelected = "menu_button_info_selected"
    case FireButtonNormal = "fire_button_normal"
    case FireButtonSelected = "fire_button_selected"
    case ShowMenuButtonNormal = "show_menu_button_normal"
    case ShowMenuButtonSelected = "show_menu_button_selected"
    case JoystickBase = "joystick_base"
    case JoystickStick = "joystick_stick"
}

enum FontName: String {
    case Wawati = "Wawati SC"
}

enum SoundName: String {
    case MissileLaunch = "missile_launch.wav"
    case Explosion = "explosion.wav"
}

enum CategoryBitmask: UInt32 {
    case playerSpaceship =  0
    case enemySpaceship =   0b10
    case playerMissile =    0b100
    case enemyMissile =     0b1000
    case screenBounds =     0b10000
}

enum CollisionType {
    case playerSpaceshipEnemySpaceship
    case playerMissileEnemySpaceship
    case enemyMissilePlayerSpaceship
}

enum ScoreValue: Int {
    case playerMissileHitEnemySpaceship =  10
    case playerSpaceshipHitEnemySpaceship =   0b10
}

enum LifePointsValue: Int {
    case enemyMissileHitPlayerSpaceship =  -10
    case enemySpaceshipHitPlayerSpaceship =  -20
    case playerMissileHitEnemySpaceship =  -25
}
