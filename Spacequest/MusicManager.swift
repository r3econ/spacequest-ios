import UIKit
import AVFoundation


private let _MusicManagerSharedInstance = MusicManager()


class MusicManager: NSObject {
    
    static let sharedInstance = MusicManager()
    fileprivate var backgroundMusicPlayer: AVAudioPlayer?
    
    
    override init() {
        
        super.init()
        
        configureBackgroundMusicPlayer()
    }
}


// MARK - Background Music

extension MusicManager
{
    fileprivate func configureBackgroundMusicPlayer() {
        
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        var error: NSError?
        
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: fileURL)
        } catch let error1 as NSError {
            error = error1
            backgroundMusicPlayer = nil
            
            print(error?.localizedDescription)
        }
        backgroundMusicPlayer!.numberOfLoops = -1;
        
        if (backgroundMusicPlayer != nil)
        {
            backgroundMusicPlayer!.prepareToPlay()
        }
    }
    
    
    func toggleBackgroundMusic() {
    
        if (backgroundMusicPlayer!.isPlaying) {
            
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
