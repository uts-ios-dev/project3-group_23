
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        window?.frame  = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width + 0.01, height: UIScreen.main.bounds.height + 0.01)
        window?.backgroundColor = UIColor.white
        
        
        if User.isLogined {
            
            loginSuccess()
            
        } else {
            logout()
        }
        
        self.window?.makeKeyAndVisible()
        
        return true
    }

    
    func loginSuccess() {
        delay(2) {
            //register umeng
        }
        self.window?.rootViewController = ESTabBarController.createTabbar()
        
    }
    
    
    func logout() {

        User.logout()
        let vc = UIStoryboard.Scene.index
        
        let nav = MTNavigationController(rootViewController: vc)
        self.window?.rootViewController = nav
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


extension AppDelegate {
    
    static var shared: AppDelegate {
        get {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                return appDelegate
            }
            return AppDelegate()
        }
    }

    
    static var root: UIViewController  {
        get {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            return appDelegate.window!.rootViewController!
        }
    }   
}
