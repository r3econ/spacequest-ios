//
// Copyright (c) 2016 Rafał Sroka
//
// Licensed under the GNU General Public License, Version 3.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at:
//
//   https://www.gnu.org/licenses/gpl-3.0.en.html
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
