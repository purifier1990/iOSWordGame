import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let gameViewModel = GameViewModel(candidates: Grid.all)
        let gameViewController = GameViewController.instance(gameViewModel)
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UINavigationController(rootViewController: gameViewController)
        window?.makeKeyAndVisible()
        return true
    }
}
