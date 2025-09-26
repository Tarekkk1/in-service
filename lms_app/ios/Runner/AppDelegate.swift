import UIKit
import Flutter
import ScreenProtectorKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private lazy var screenProtectorKit = { return ScreenProtectorKit(window: window) }()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Configure screenshot prevention
        screenProtectorKit.configurePreventionScreenshot()
        
        // Setup screen recording observer
        if #available(iOS 11.0, *) {
            screenProtectorKit.screenRecordObserver { isCaptured in
                // When screen recording is detected, apply blur effect
                if isCaptured {
                    self.screenProtectorKit.enabledBlurScreen()
                } else {
                    self.screenProtectorKit.disableBlurScreen()
                }
            }
        }
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        super.applicationDidBecomeActive(application)
        screenProtectorKit.enabledPreventScreenshot()
        screenProtectorKit.disableBlurScreen()
    }
    
    override func applicationWillResignActive(_ application: UIApplication) {
        super.applicationWillResignActive(application)
        screenProtectorKit.disablePreventScreenshot()
        screenProtectorKit.enabledBlurScreen() // This prevents sensitive data from appearing in the app switcher
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        super.applicationWillTerminate(application)
        // Clean up observers when app terminates
        screenProtectorKit.removeAllObserver()
    }
}
