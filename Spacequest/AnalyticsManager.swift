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
    
    
    private func configureGoogleAnalytics() {
        
        GAI.sharedInstance().trackerWithTrackingId(kGoogleAnalyticsAppID)
        
        // Set app version.
        let bundleInfo = NSBundle.mainBundle().infoDictionary as Dictionary!
        let version = bundleInfo["CFBundleVersion"] as! String
        let shortVersion = bundleInfo["CFBundleShortVersionString"] as! String
        
        GAI.sharedInstance().defaultTracker.set(kGAIAppVersion, value: String(format: "%@ (%@)", shortVersion, version))
    }
    
    
    func trackGAEvent(category: String, action: String, label: String, value: NSNumber) {
        
        let event = GAIDictionaryBuilder.createEventWithCategory(category, action: action, label: label, value: value).build();
        
        // Submit event to Google Analytics.
        GAI.sharedInstance().defaultTracker.send(event as [NSObject : AnyObject])
    }
    
    
    func trackScene(name: String) {
        
        GAI.sharedInstance().defaultTracker.set(kGAIScreenName, value: name)
        
        let event = GAIDictionaryBuilder.createScreenView().build()
        
        GAI.sharedInstance().defaultTracker.send(event as [NSObject : AnyObject])
    }
}