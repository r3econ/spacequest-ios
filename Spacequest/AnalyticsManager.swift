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
import Foundation

class AnalyticsManager: NSObject{

    static let sharedInstance = AnalyticsManager()

    override init() {
        super.init()
        // Configure 3rd party SDKs here
    }
}

extension AnalyticsManager {

    func trackScene(_ name: String) {
        // TODO: Implement tracking
    }

}
