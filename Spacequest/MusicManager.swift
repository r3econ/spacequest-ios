import UIKit
import AVFoundation


class MusicManager: NSObject {
    
    static let shared = MusicManager()
    fileprivate var backgroundMusicPlayer: AVAudioPlayer!
    
    override init() {
        super.init()
        self.configureBackgroundMusicPlayer()
    }
    
}

// MARK - Background Music

extension MusicManager{

    fileprivate func configureBackgroundMusicPlayer() {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        do {
            self.backgroundMusicPlayer = try AVAudioPlayer(contentsOf: fileURL)
            self.backgroundMusicPlayer.numberOfLoops = -1;
            self.backgroundMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            self.backgroundMusicPlayer = nil
            
            print(error.localizedDescription)
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
