import UIKit
import AVFoundation


private let _MusicManagerSharedInstance = MusicManager()


class MusicManager: NSObject {
    
    static let sharedInstance = MusicManager()
    private var backgroundMusicPlayer: AVAudioPlayer?
    
    
    override init() {
        
        super.init()
        
        configureBackgroundMusicPlayer()
    }
}


// MARK - Background Music

extension MusicManager
{
    private func configureBackgroundMusicPlayer() {
        
        let fileURL = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("background", ofType: "mp3")!)
        var error: NSError?
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOfURL: fileURL)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
        }
        backgroundMusicPlayer!.numberOfLoops = -1;
        
        if (backgroundMusicPlayer != nil)
        {
            backgroundMusicPlayer!.prepareToPlay()
        }
    }
    
    
    func toggleBackgroundMusic() {
    
        if (backgroundMusicPlayer!.playing) {
            
            backgroundMusicPlayer!.pause()
        }
        else
        {
            backgroundMusicPlayer!.play()
        }
    }
    
    
    func playBackgroundMusic() {
        
        backgroundMusicPlayer!.play()
    }
    
    
    func pauseBackgroundMusic() {
        
        backgroundMusicPlayer!.pause()
    }
}