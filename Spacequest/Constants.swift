
enum CategoryBitmask: UInt32 {
    
    case PlayerSpaceship = 0
    case EnemySpaceship = 0b10
    case PlayerMissile = 0b100
    case EnemyMissile = 0b1000
}


enum ImageName: String {
    
    case PlayerSpaceship = "player_spaceship"
    case EnemySpaceship = "enemy_spaceship"
    case Missile = "missile"
    case Lifebar = "lifebar"
    case BackgroundGradient = "background_gradient"
    case BackgroundCosmicDust = "background_cosmic_dust"
}


enum SoundName: String {
    
    case MissileLaunch = "missile_launch.wav"
}