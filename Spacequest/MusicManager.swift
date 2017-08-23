import UIKit
import AVFoundation

private let _MusicManagerSharedInstance = MusicManager()

class MusicManager: NSObject {
    
    static let sharedInstance = MusicManager()
    fileprivate var backgroundMusicPlayer: AVAudioPlayer?
    
    override init() {
        super.init()
        
        self.configureBackgroundMusicPlayer()
    }
    
}

// MARK - Background Music

extension MusicManager{

    fileprivate func configureBackgroundMusicPlayer() {
        
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        var error: NSError?
        
        do {
            self.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: fileURL)
        } catch let error1 as NSError {
            error = error1
            self.backgroundMusicPlayer = nil
            
            print(error?.localizedDescription)
        }
        self.backgroundMusicPlayer!.numberOfLoops = -1;
        
        if (self.backgroundMusicPlayer != nil) {
            self.backgroundMusicPlayer!.prepareToPlay()
        }
    }
    
    func toggleBackgroundMusic() {
    
        if (self.backgroundMusicPlayer!.isPlaying) {
            self.backgroundMusicPlayer!.pause()
        }
        else {
            self.backgroundMusicPlayer!.play()
        }
    }
    
    func playBackgroundMusic() {
        self.backgroundMusicPlayer!.play()
    }
    
    func pauseBackgroundMusic() {
        self.backgroundMusicPlayer!.pause()
    }
}
