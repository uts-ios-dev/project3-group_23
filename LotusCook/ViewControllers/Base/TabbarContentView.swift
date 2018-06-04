
import Foundation
//import pop
import UIKit

extension ESTabBarController {
    /// create Tab
    static func createTabbar() -> UIViewController {
        let tabBarController = ESTabBarController()

        
        let v1 = UIStoryboard.Scene.main
        let v2 = UIStoryboard.Scene.recipes
        let v3 = UIStoryboard.Scene.shopping
        let v4 = UIStoryboard.Scene.mine
        
        let n1 = MTNavigationController(rootViewController: v1)
        let n2 = MTNavigationController(rootViewController: v2)
        let n3 = MTNavigationController(rootViewController: v3)
        let n4 = MTNavigationController(rootViewController: v4)
        
        n1.tabBarItem = ESTabBarItem.init(IrregularityBasicContentView(), title: "Meals", image: #imageLiteral(resourceName: "tab1_nor"), selectedImage: #imageLiteral(resourceName: "tab1_sel"))
        n2.tabBarItem = ESTabBarItem.init(IrregularityBasicContentView(), title: "Recipes", image: #imageLiteral(resourceName: "tab2_nor"), selectedImage: #imageLiteral(resourceName: "tab2_sel"))
        n3.tabBarItem = ESTabBarItem.init(IrregularityBasicContentView(), title: "Shopping", image: #imageLiteral(resourceName: "tab3_nor"), selectedImage: #imageLiteral(resourceName: "tab3_sel"))
        n4.tabBarItem = ESTabBarItem.init(IrregularityBasicContentView(), title: "Mine", image: #imageLiteral(resourceName: "tab4_nor"), selectedImage: #imageLiteral(resourceName: "tab4_sel"))
        
        n1.tabBarItem.titlePositionAdjustment = UIOffsetMake(0.0, -10)
        tabBarController.viewControllers = [n1, n2, n3, n4]

        tabBarController.tabBar.shadowImage = #imageLiteral(resourceName: "Transparent")
        //tabBarController.tabBar.backgroundImage = #imageLiteral(resourceName: "background_dark")
        tabBarController.tabBar.backgroundImage = UIImage.image(withColor: .white)
        tabBarController.tabBar.applyPlainShadow()
        
        return tabBarController
    }


}

class MTBasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        highlightTextColor = UIColor(red:0.60, green:0.60, blue:0.60, alpha:1.00)
        //iconColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.00)
        //highlightIconColor = MTNavigationBarBackgroundColor
        
        backdropColor = .white
        highlightBackdropColor = .white
        renderingMode = .alwaysOriginal     //render mode
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class BasicContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        textColor = UIColor.red
        highlightTextColor = UIColor.red
        //iconColor = UIColor.init(white: 175.0 / 255.0, alpha: 1.0)
        //highlightIconColor = UIColor.init(red: 254/255.0, green: 73/255.0, blue: 42/255.0, alpha: 1.0)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

class BouncesContentView: BasicContentView {
    
    public var duration = 0.3
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        //self.bounceAnimation()
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        //self.bounceAnimation()
        completion?()
    }
    
    func bounceAnimation() {
        let impliesAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        impliesAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        impliesAnimation.duration = duration * 2
        impliesAnimation.calculationMode = kCAAnimationCubic
        imageView.layer.add(impliesAnimation, forKey: nil)
    }
}


class IrregularityBasicContentView: BouncesContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textColor = UIColor(hex: 0x777777)
        highlightTextColor = MTColor.main
        //iconColor = UIColor(red:0.61, green:0.61, blue:0.61, alpha:1.00)
        //highlightIconColor = MTNavigationBarBackgroundColor
        backdropColor = .white
        highlightBackdropColor = .white
        renderingMode = .alwaysOriginal     //render mode
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


