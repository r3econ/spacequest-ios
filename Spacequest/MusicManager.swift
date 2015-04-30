import UIKit
import AVFoundation


private let _MusicManagerSharedInstance = MusicManager()


class MusicManager: NSObject
{
    static let sharedInstance = MusicManager()
    private var backgroundMusicAudioPlayer: AVAudioPlayer?
    
    
    func startPlayingBackgroundMusic()
    {
        var fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "mp3")!)
        
        var error: NSError?
        
        backgroundMusicAudioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: &error)
        
        if (backgroundMusicAudioPlayer != nil)
        {
            backgroundMusicAudioPlayer!.prepareToPlay()
            backgroundMusicAudioPlayer!.play()
        }
        
        if error != nil
        {
            println(error)
        }
    }
}