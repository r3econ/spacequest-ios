

enum ImageName: String
{
    case PlayerSpaceship = "player_spaceship"
    case EnemySpaceship = "enemy_spaceship"
    case Missile = "player_missile"
    case Lifebar = "lifebar"
    case GameBackgroundPad = "game_background_ipad"
    case GameBackgroundPhone = "game_background_iphone"
    case MenuBackgroundPad = "menu_background_ipad"
    case MenuBackgroundPhone = "menu_background_iphone"
    case MenuButtonRestartNormal = "menu_button_restart_normal"
    case MenuButtonRestartSelected = "menu_button_restart_selected"
    case MenuButtonResumeNormal = "menu_button_resume_normal"
    case MenuButtonResumeSelected = "menu_button_resume_selected"
    case FireButtonNormal = "fire_button_normal"
    case FireButtonSelected = "fire_button_selected"
    case ShowMenuButtonNormal = "show_menu_button_normal"
    case ShowMenuButtonSelected = "show_menu_button_selected"
    case JoystickBase = "joystick_base"
    case JoystickStick = "joystick_stick"
}


enum SoundName: String
{
    case MissileLaunch = "missile_launch.wav"
    case Explosion = "explosion.wav"
}


enum CategoryBitmask: UInt32
{
    case PlayerSpaceship =  0
    case EnemySpaceship =   0b10
    case PlayerMissile =    0b100
    case EnemyMissile =     0b1000
    case ScreenBounds =     0b10000
}


enum CollisionType
{
    case PlayerSpaceshipEnemySpaceship
    case PlayerMissileEnemySpaceship
    case EnemyMissilePlayerSpaceship
}