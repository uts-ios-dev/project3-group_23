
import UIKit


private let NavBarTitleFont = UIFont.systemFont(ofSize: 18, weight: .medium)

enum navigationBarStyle {
    case white
    case main
}

class MTBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        view.backgroundColor = MTColor.pageback
        
        if #available(iOS 11.0, *) {
            if let view = self.view.subviews.first {
                if view.isKind(of: UIScrollView.self) {
                    (view as! UIScrollView).contentInsetAdjustmentBehavior = .never
                }
            }
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    
    /// 导航背景
    var style: navigationBarStyle = .white
    
    /// 状态栏颜色设置
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if style == .white {
            return .default
        } else {
            return .lightContent
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if style == .white {
            navigationController?.navigationBar.setBackgroundImage(UIImage.image(withColor: MTNavigationBarBackgroundColor), for: .default)
            (navigationController as? MTNavigationController)?.titleColor = titleTextColor
        } else {
            navigationController?.navigationBar.setBackgroundImage(UIImage.image(withColor: MTColor.main), for: .default)
            (navigationController as? MTNavigationController)?.titleColor = .white
        }
    }

}

extension MTBaseViewController {
    // 添加导航左侧按钮
    func addNavigationBarLeftButton(_ taget: Any, action: Selector = #selector(popBack), image: UIImage? = UIImage(named: "nav_back")) {
        let leftButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        if style == .white {
            leftButton.setImage(image, for: .normal)
        } else {
            leftButton.setImage(image, for: .normal)
        }

        //leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10)
        //leftButton.contentHorizontalAlignment = .left
        leftButton.addTarget(taget, action: action, for: .touchUpInside)
        
        // here where the magic happens, you can shift it where you like
        leftButton.transform = CGAffineTransform(translationX: -10, y: 0)
        // add the button to a container, otherwise the transform will be ignored
        let suggestButtonContainer = UIView(frame: leftButton.frame)
        suggestButtonContainer.addSubview(leftButton)
        let suggestButtonItem = UIBarButtonItem(customView: suggestButtonContainer)
        
        self.navigationItem.leftBarButtonItem = suggestButtonItem
        
    }
    
    // 添加导航右侧按钮
    @discardableResult
    func addNavigationBarRightButton(_ taget: Any, action: Selector, image: UIImage)  -> UIButton {
        let rightButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        rightButton.setImage(image, for: .normal)
        rightButton.addTarget(taget, action: action, for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        return rightButton
    }
    
    // 添加导航右侧按钮
    @discardableResult
    func addNavigationBarRightButton(_ taget: Any, action: Selector, text: String, color: UIColor? = .white) -> UIButton {
        let rightButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 68, height: 36))
        rightButton.contentHorizontalAlignment = .right
        rightButton.setTitle(text, for: .normal)
        rightButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        rightButton.setTitleColor(color, for: .normal)
        rightButton.addTarget(taget, action: action, for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        return rightButton
    }
    

    
    // 返回
    @objc func popBack() {
        if let root = self.navigationController?.viewControllers[0] {
            if root == self {
                self.navigationController?.dismiss(animated: true, completion: nil)
            } else {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }

    func showMessage(_ message: String) {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 24))
        titleLabel.textAlignment = .center
        titleLabel.layer.cornerRadius = 3
        titleLabel.layer.masksToBounds = true
        titleLabel.text = message
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.backgroundColor = UIColor(red:0.26, green:0.28, blue:0.33, alpha:1.00)
        titleLabel.textColor = UIColor.white
        let layer = titleLabel.layer
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 3
        //titleLabel.sizeToFit()
        titleLabel.center = view.center
        view.addSubview(titleLabel)
        
        
        delay(1.5) {
            titleLabel.removeFromSuperview()
        }
        
    }
}

extension UIViewController: StatusController {
    
    func placeholder( handle: (()->())? = nil) {
        
        let status = Status(title: "not meals planned yet!", description: "", actionTitle: "add one", image: #imageLiteral(resourceName: "empty")) {
            self.hideStatus()
            handle?()
        }
        show(status: status)
        

    }
    
}


