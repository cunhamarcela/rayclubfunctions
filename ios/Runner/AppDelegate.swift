import Flutter
import UIKit
import AuthenticationServices

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // Handle URL schemes for authentication callbacks
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    print("🔍 AppDelegate: Received URL \(url.absoluteString)")
    
    // Let Flutter plugins handle the URL
    return super.application(app, open: url, options: options)
  }
  
  // Handle universal links
  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    // Handle universal links for Sign in with Apple
    if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
       let incomingURL = userActivity.webpageURL {
        print("🔍 AppDelegate: Received universal link \(incomingURL.absoluteString)")
    }
    
    // Forward to super implementation which handles Universal Links
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
  }
}
