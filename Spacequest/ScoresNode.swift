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

class ScoresNode: SKLabelNode {
    
    var value: Int = 0 {
        didSet {
            update()
        }
    }
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()
        
        fontSize = 18.0
        fontColor = UIColor(white: 1, alpha: 0.7)
        fontName = FontName.Wawati.rawValue
        horizontalAlignmentMode = .left;
        
        update()
    }
    
    // MARK: - Configuration
    
    func update() {
        text = "Score: \(value)"
    }
    
}
