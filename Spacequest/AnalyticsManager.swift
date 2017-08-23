import UIKit
import Foundation

private let _AnalyticsManagerSharedInstance = MusicManager()

/**
Google Analytics tokens.
*/
private let kGoogleAnalyticsAppID = "UA-47897348-7"


class AnalyticsManager: NSObject
{
    static let sharedInstance = AnalyticsManager()

    override init() {
        
        super.init()
        
        configureGoogleAnalytics()
    }
}


// MARK: - GoogleAnalytics

extension AnalyticsManager {
    
    
    fileprivate func configureGoogleAnalytics() {
        
        GAI.sharedInstance().tracker(withTrackingId: kGoogleAnalyticsAppID)
        
        // Set app version.
        let bundleInfo = Bundle.main.infoDictionary as Dictionary!
        let version = bundleInfo?["CFBundleVersion"] as! String
        let shortVersion = bundleInfo?["CFBundleShortVersionString"] as! String
        
        GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: String(format: "%@ (%@)", shortVersion, version))
    }
    
    
    func trackGAEvent(_ category: String, action: String, label: String, value: NSNumber) {
        
        let event = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value).build();
        
        // Submit event to Google Analytics.
        GAI.sharedInstance().defaultTracker.send(event as! [AnyHashable: Any])
    }
    
    
    func trackScene(_ name: String) {
        
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: name)
        
        let event = GAIDictionaryBuilder.createScreenView().build()
        
        GAI.sharedInstance().defaultTracker.send(event as! [AnyHashable: Any])
    }
}
