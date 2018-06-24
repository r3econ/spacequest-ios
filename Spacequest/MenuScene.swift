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

import SpriteKit

class MenuScene: SKScene {
    
    private var background: SKSpriteNode?

    // MARK: - Scene lifecycle
    
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        configureBackground()
    }
    
    // MARK: - Configuration

    private func configureBackground() {
        background = SKSpriteNode(imageNamed: ImageName.MenuBackgroundPhone.rawValue)
        background!.size = size
        background!.position = CGPoint(x: size.width/2, y: size.height/2)
        background!.zPosition = -1000
        addChild(background!)
    }
    
}
