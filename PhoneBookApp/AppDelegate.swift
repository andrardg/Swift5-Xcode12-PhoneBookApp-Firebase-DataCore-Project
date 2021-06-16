import UIKit
import CoreData
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate {
    var window:UIWindow?
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
    }

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
           didReceive response: UNNotificationResponse, withCompletionHandler
           completionHandler: @escaping () -> Void) {
           print(response.notification.request.content.userInfo)
           return completionHandler()
       }

       // called if app is running in foreground
       func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent
           notification: UNNotification, withCompletionHandler completionHandler:
           @escaping (UNNotificationPresentationOptions) -> Void) {

           return completionHandler(UNNotificationPresentationOptions.alert)
       }
    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceServce.saveContext()
    }

}

