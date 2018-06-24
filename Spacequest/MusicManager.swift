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
    private var backgroundMusicPlayer: AVAudioPlayer!
    
    override init() {
        super.init()
        configureBackgroundMusicPlayer()
    }
    
}

// MARK - Background Music

extension MusicManager{

    private func configureBackgroundMusicPlayer() {
        let fileURL = URL(fileURLWithPath: Bundle.main.path(forResource: "background", ofType: "mp3")!)
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: fileURL)
            backgroundMusicPlayer.numberOfLoops = -1;
            backgroundMusicPlayer.prepareToPlay()
        } catch let error as NSError {
            backgroundMusicPlayer = nil
            
            print(error.localizedDescription)
        }
    }
    
    func toggleBackgroundMusic() {
        if (backgroundMusicPlayer!.isPlaying) {
            backgroundMusicPlayer!.pause()
        }
        else {
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
