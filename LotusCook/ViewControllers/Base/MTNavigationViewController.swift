
import UIKit

let MTNavigationBarBackgroundColor = UIColor.white
let titleTextColor = UIColor(hex: 0x444444)


/// MTNavigationController
class MTNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationBar.isTranslucent = false   // not transparent
        self.navigationBar.backgroundColor = nil
        navigationBar.shadowImage = UIImage()       // hide bottom border
        navigationBar.barStyle = .default
        
        navigationBar.setBackgroundImage(UIImage.imageWith(MTNavigationBarBackgroundColor), for: .default)
        navigationBar.tintColor = MTColor.main
        let textAttributes = [
            NSAttributedStringKey.foregroundColor: MTColor.main,
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)
            ] as [NSAttributedStringKey : Any]
        
        navigationBar.titleTextAttributes = textAttributes
        
        if responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.delegate = self
            delegate = self
        }
        
    }
    
    var titleColor: UIColor = titleTextColor {
        didSet {
            let textAttributes = [ NSAttributedStringKey.foregroundColor: titleColor, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)] as [NSAttributedStringKey : Any]
            navigationBar.titleTextAttributes = textAttributes
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if self.viewControllers.count > 0 {
            //UIApplication.shared.statusBarStyle = .default
        }
        
        super.pushViewController(viewController, animated: animated)
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        if self.viewControllers.count == 2 {
            //UIApplication.shared.statusBarStyle = .lightContent
        }
        return super.popViewController(animated: animated)
    }
    
    /// disables swipe gestures
    public func disableSwipeBack() {
        interactivePopGestureRecognizer?.isEnabled = false
    }
    
    /// enables swipe gestures
    public func enableSwipeBack() {
        interactivePopGestureRecognizer?.isEnabled = true
    }
    
    /// toggles swipe gestures
    public func toggleSwipeBack() {
        guard let status = interactivePopGestureRecognizer?.isEnabled else {
            return
        }
        interactivePopGestureRecognizer?.isEnabled = !status
    }
}
extension MTNavigationController: UIGestureRecognizerDelegate {
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        if responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) && animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        if responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) && animated {
            interactivePopGestureRecognizer?.isEnabled = false
        }
        
        return super.popToViewController(viewController, animated: false)
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer == interactivePopGestureRecognizer {
            if self.viewControllers.count < 2 || self.visibleViewController == self.viewControllers[0] {
                return false
            }
        }
        
        return true
    }

}

extension MTNavigationController: UINavigationControllerDelegate {
    //MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if responds(to: #selector(getter: UINavigationController.interactivePopGestureRecognizer)) {
            interactivePopGestureRecognizer?.isEnabled = true
        }
    }
}


extension UINavigationController {
   
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
    
    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}

fileprivate extension UIImage {

  
    static func imageWith(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}

