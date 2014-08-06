

enum ImageName: String
{
    case PlayerSpaceship = "player_spaceship"
    case EnemySpaceship = "enemy_spaceship"
    case Missile = "player_missile"
    case Lifebar = "lifebar"
    case GameBackgroundPad = "game_background_ipad"
    case GameBackgroundPhone = "game_background_iphone"
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