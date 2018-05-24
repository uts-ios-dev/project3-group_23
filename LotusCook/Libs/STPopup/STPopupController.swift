//  Created by Luochun on 2017/2/12.
//  Copyright © 2017年 Mantis. All rights reserved.
//

import UIKit

enum STPopupControllerTransitioningAction {
    case present, dismiss
}

enum STPopupStyle {
    case formSheet, bottomSheet
}

enum STPopupTransitionStyle {
    case slideVertical, fade, custom
}

class STPopupController: NSObject {
    var style: STPopupStyle?
    var transitionStyle = STPopupTransitionStyle.slideVertical
    var transitioning: STPopupControllerTransitioning?
    var navigationBarHidden = false {
        didSet {
            set(navigationBarHidden: navigationBarHidden, animated: false)
        }
    }
    var hidesCloseButton = false {
        didSet {
            updateNavigationBar(animated: false)
        }
    }
    var navigationBar: STPopupNavigationBar?
    var backgroundView: UIView? {
        willSet {
            backgroundView?.removeFromSuperview()
            newValue?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            newValue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgViewDidTap)))

            containerViewController?.view.insertSubview(newValue!, at: 0)
        }
    }
    
    /// 点击背景是否退出
    var tapBackgroundViewToDismiss: Bool = true

    /// 滑动多少退出
    var dismissOffsetY: CGFloat = 100
    
    var containerView: UIView?
    var topViewController: UIViewController? {
        return viewControllers.last
    }
    var presented: Bool {
        return containerViewController!.presentingViewController != nil
    }

    var containerViewController: STPopupContainerViewController?

    fileprivate let STPopupBottomSheetExtraHeight: CGFloat = 80

    private var viewControllers: [UIViewController] = []
    private var defaultTitleLabel: UILabel?
    private var defaultLeftBarItem: STPopupLeftBarItem?
    private var keyboardInfo: [String: Any]?
    private var observing = false
    fileprivate var contentView: UIView?
    fileprivate let transitioningSlideVertical = STPopupControllerTransitioningSlideVertical()
    fileprivate let transitioningFade = STPopupControllerTransitioningFade()

    override init() {
        super.init()

        containerViewController = STPopupContainerViewController()
        containerViewController?.view.backgroundColor = .clear

        let flag = UIDevice.current.systemVersion.compare("8.0", options: .numeric) != .orderedAscending
        containerViewController?.modalPresentationStyle = flag ? .overCurrentContext : .custom

        containerViewController?.transitioningDelegate = self

        setupBackgroundView()
        setupContainerView()
        setupNavigationBar()
    }

    convenience init(rootViewController: UIViewController) {
        self.init()
        push(rootViewController, animated: false)
    }

    deinit {
        destroyObservers()
        viewControllers.forEach {
            $0.popupController = nil
            destroyObservers(of: $0)
        }
    }

    func setupObservers() {
        if observing { return }
        observing = true

        navigationBar?.addObserver(self, forKeyPath: "tintColor", options: .new, context: nil)
        navigationBar?.addObserver(self, forKeyPath: "titleTextAttributes", options: .new, context: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: .UIApplicationDidChangeStatusBarOrientation, object: nil)

        let keyboardShowing = #selector(keyboardWillShow)
        let items: [(Selector, Notification.Name)] = [
            (keyboardShowing, .UIKeyboardWillShow),
            (keyboardShowing, .UIKeyboardWillChangeFrame),
            (#selector(keyboardWillHide), .UIKeyboardWillHide),
            (#selector(firstResponderDidChange), STPopupFirstResponderDidChange)
        ]

        items.forEach {
            NotificationCenter.default.addObserver(self, selector: $0.0, name: $0.1, object: nil)
        }
    }

    func destroyObservers() {
        if !observing { return }

        observing = false

        navigationBar?.removeObserver(self, forKeyPath: "tintColor")
        navigationBar?.removeObserver(self, forKeyPath: "titleTextAttributes")
        NotificationCenter.default.removeObserver(self)
    }

    func setupObservers(for viewController: UIViewController) {
        viewController.addObserver(self, forKeyPath: "contentSizeInPopup", options: .new, context: nil)
        viewController.addObserver(self, forKeyPath: "landscapeContentSizeInPopup", options: .new, context: nil)

        let keys = [
            "title",
            "titleView",
            "leftBarButtonItem",
            "leftBarButtonItems",
            "rightBarButtonItem",
            "rightBarButtonItems",
            "hidesBackButton"
        ]

        keys.forEach {
            viewController.navigationItem.addObserver(self, forKeyPath: $0, options: .new, context: nil)
        }
    }

    func destroyObservers(of viewController: UIViewController) {
        viewController.removeObserver(self, forKeyPath: "contentSizeInPopup")
        viewController.removeObserver(self, forKeyPath: "landscapeContentSizeInPopup")

        let keys = [
            "title",
            "titleView",
            "leftBarButtonItem",
            "leftBarButtonItems",
            "rightBarButtonItem",
            "rightBarButtonItems",
            "hidesBackButton"
        ]

        keys.forEach {
            viewController.navigationItem.removeObserver(self, forKeyPath: $0)
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        let topViewController = self.topViewController!
        let condition = topViewController.isViewLoaded && topViewController.view.superview != nil
        if object is STPopupNavigationBar || object is UINavigationItem {
            if condition {
                updateNavigationBar(animated: false)
            }
        } else if object is UIViewController {
            if condition {
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    self.layoutContainerView()
                }, completion: nil)
            }
        }
    }

    // MARK: - STPopupController present & dismiss & push & pop
    var retainedPopupControllers: Set<STPopupController> = []

    func present(in viewController: UIViewController) {
        present(in: viewController, completion: nil)
    }

    func present(in viewController: UIViewController, completion: (() -> Void)?) {
        if presented { return }

        setupObservers()

        retainedPopupControllers.insert(self)

        let controller = viewController.tabBarController ?? viewController
        controller.present(containerViewController!, animated: true, completion: completion)
    }

    func dismiss() {
        dismiss(with: nil)
    }

    func dismiss(with completion: (() -> Void)?) {
        if !presented { return }

        destroyObservers()

        containerViewController?.dismiss(animated: true, completion: {
            _ = self.retainedPopupControllers.remove(self)
            if let completion = completion {
                completion()
            }
        })
    }

    func push(_ viewController: UIViewController, animated: Bool) {
        let topViewController = self.topViewController

        viewController.popupController = self

        viewControllers.append(viewController)

        if presented {
            transit(from: topViewController!, toVC: viewController, animated: animated)
        }

        setupObservers(for: viewController)
    }

    func popViewController(_ animated: Bool) {
        if viewControllers.count <= 1 {
            dismiss()
            return
        }

        let topViewController = self.topViewController
        destroyObservers(of: topViewController!)
        viewControllers.remove(topViewController!)

        if presented {
            transit(from: topViewController!, toVC: self.topViewController!, animated: animated)
        }

        topViewController?.popupController = nil
    }

    func transit(from fromVC: UIViewController, toVC: UIViewController, animated: Bool) {
        fromVC.beginAppearanceTransition(false, animated: animated)
        toVC.beginAppearanceTransition(true, animated: animated)

        fromVC.willMove(toParentViewController: nil)
        containerViewController?.addChildViewController(toVC)

        if animated {
            UIGraphicsBeginImageContextWithOptions(fromVC.view.bounds.size, false, UIScreen.main.scale)
            fromVC.view.drawHierarchy(in: fromVC.view.bounds, afterScreenUpdates: false)

            let capturedView = UIImageView(image: UIGraphicsGetImageFromCurrentImageContext())
            UIGraphicsEndImageContext()

            capturedView.frame = CGRect(origin: contentView!.frame.origin, size: fromVC.view.bounds.size)

            containerView?.insertSubview(capturedView, at: 0)

            fromVC.view.removeFromSuperview()

            containerView?.isUserInteractionEnabled = false
            toVC.view.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.layoutContainerView()
                self.contentView?.addSubview(toVC.view)
                capturedView.alpha = 0
                toVC.view.alpha = 1
                self.containerViewController?.setNeedsStatusBarAppearanceUpdate()
            }, completion: { (_) in
                capturedView.removeFromSuperview()
                fromVC.removeFromParentViewController()

                self.containerView?.isUserInteractionEnabled = true
                toVC.didMove(toParentViewController: self.containerViewController)

                fromVC.endAppearanceTransition()
                toVC.endAppearanceTransition()
            })
            updateNavigationBar(animated: animated)
        } else {
            layoutContainerView()
            contentView?.addSubview(toVC.view)
            containerViewController?.setNeedsStatusBarAppearanceUpdate()
            updateNavigationBar(animated: animated)

            fromVC.view.removeFromSuperview()
            fromVC.removeFromParentViewController()

            toVC.didMove(toParentViewController: containerViewController)

            fromVC.endAppearanceTransition()
            toVC.endAppearanceTransition()
        }
    }

    func updateNavigationBar(animated: Bool) {
        guard let topViewController = topViewController else {
            return
        }
        let shouldAnimateDefaultLeftBarItem = animated && navigationBar?.topItem?.leftBarButtonItem == defaultLeftBarItem

        let lastTitleView = navigationBar?.topItem?.titleView
        navigationBar?.items = [UINavigationItem()]
        if topViewController.navigationItem.leftBarButtonItems == nil {
            if topViewController.navigationItem.hidesBackButton {
                topViewController.navigationItem.leftBarButtonItems = nil
            } else {
                navigationBar?.topItem?.leftBarButtonItems = [defaultLeftBarItem!]
            }
        }
        navigationBar?.topItem?.rightBarButtonItems = topViewController.navigationItem.rightBarButtonItems
        if hidesCloseButton && topViewController == viewControllers.first && navigationBar?.topItem?.leftBarButtonItem == defaultLeftBarItem {
            navigationBar?.topItem?.leftBarButtonItems = nil
        }

        if animated {
            var fromTitleView: UIView?, toTitleView: UIView?
            if lastTitleView == defaultTitleLabel {
                let tempLabel = UILabel(frame: defaultTitleLabel!.frame)
                tempLabel.textColor = defaultTitleLabel?.textColor
                tempLabel.font = defaultTitleLabel?.font
                tempLabel.attributedText = NSAttributedString(string: defaultTitleLabel?.text ?? "", attributes: navigationBar?.titleTextAttributes)
                fromTitleView = tempLabel
            } else {
                fromTitleView = lastTitleView
            }

            if let titleView = topViewController.navigationItem.titleView {
                toTitleView = titleView
            } else {
                let title = topViewController.title ?? (topViewController.navigationItem.title ?? "")
                defaultTitleLabel = UILabel()
                defaultTitleLabel?.attributedText = NSAttributedString(string: title, attributes: navigationBar!.titleTextAttributes)
                defaultTitleLabel?.sizeToFit()
                toTitleView = defaultTitleLabel
            }

            navigationBar?.addSubview(fromTitleView!)
            navigationBar?.topItem?.titleView = toTitleView
            toTitleView?.alpha = 0

            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                fromTitleView?.alpha = 0
                toTitleView?.alpha = 1
            }, completion: { (_) in
                fromTitleView?.removeFromSuperview()
            })
        } else {
            if let titleView = topViewController.navigationItem.titleView {
                navigationBar?.topItem?.titleView = titleView
            } else {
                let title = topViewController.title ?? (topViewController.navigationItem.title ?? "")
                defaultTitleLabel = UILabel()
                defaultTitleLabel?.attributedText = NSAttributedString(string: title, attributes: navigationBar!.titleTextAttributes)
                defaultTitleLabel?.sizeToFit()
                navigationBar?.topItem?.titleView = defaultTitleLabel
            }
        }

        defaultLeftBarItem?.tintColor = navigationBar?.tintColor
        defaultLeftBarItem?.set(viewControllers.count > 1 ? .arrow : .cross, animated: shouldAnimateDefaultLeftBarItem)
    }

    func set(navigationBarHidden: Bool, animated: Bool) {
        navigationBar?.alpha = navigationBarHidden ? 1 : 0

        if !animated {
            layoutContainerView()
            navigationBar?.isHidden = navigationBarHidden
            return
        }

        if !navigationBarHidden {
            navigationBar?.isHidden = navigationBarHidden
        }

        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.navigationBar?.alpha = navigationBarHidden ? 0 : 1
            self.layoutContainerView()
        }, completion: { _ in
            self.navigationBar?.isHidden = navigationBarHidden
        })
    }

    func layoutContainerView() {

        guard let containerViewController = containerViewController else { return }

        backgroundView?.frame = containerViewController.view.bounds

        let navigationBarHeight = navigationBarHidden ? 0 : preferredNavigationBarHeight
        let containerViewWidth = contentSizeOfTopView.width
        var containerViewHeight = contentSizeOfTopView.height + navigationBarHeight
        var containerViewY = (containerViewController.view.bounds.height - containerViewHeight) / 2

        if style == .bottomSheet {
            containerViewY = containerViewController.view.bounds.height - containerViewHeight
            containerViewHeight += STPopupBottomSheetExtraHeight
        }

        containerView?.frame = CGRect(x: (containerViewController.view.bounds.width - containerViewWidth) / 2, y: containerViewY, width: containerViewWidth, height: containerViewHeight)

        navigationBar?.frame = CGRect(x: 0, y: 0, width: containerViewWidth, height: preferredNavigationBarHeight)
        contentView?.frame = CGRect(x: 0, y: navigationBarHeight, width: contentSizeOfTopView.width, height: contentSizeOfTopView.height)

        let topViewController = self.topViewController
        topViewController?.view.frame = contentView!.bounds
    }

    var contentSizeOfTopView: CGSize {
        var contentSize = CGSize.zero

        guard let topViewController = topViewController else { return contentSize }

        switch UIApplication.shared.statusBarOrientation {
        case .landscapeLeft, .landscapeRight:
            contentSize = topViewController.landscapeContentSizeInPopup
            if contentSize == .zero {
                contentSize = topViewController.contentSizeInPopup
            }
        default:
            contentSize = topViewController.contentSizeInPopup
        }

        return contentSize
    }

    var preferredNavigationBarHeight: CGFloat {
        let navigationController = UINavigationController()
        return navigationController.navigationBar.bounds.height
    }

    func setupBackgroundView() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.5)
    }

    func setupContainerView() {
        containerView = UIView()
        containerView?.backgroundColor = UIColor.white
        containerView?.layer.cornerRadius = 4
        containerView?.clipsToBounds = true
        containerViewController?.view.addSubview(containerView!)

        contentView = UIView()
        containerView?.addSubview(contentView!)
    }

    func setupNavigationBar() {
        navigationBar = STPopupNavigationBar()
        navigationBar?.touchEventDelegate = self
        navigationBar?.shadowImage = UIImage()  //隐藏BottomHairline
        containerView?.addSubview(navigationBar!)

        defaultTitleLabel = UILabel()
        defaultLeftBarItem = STPopupLeftBarItem(with: self, action: #selector(leftBarItemDidTap))
    }

    @objc func leftBarItemDidTap() {
        switch defaultLeftBarItem!.type {
        case .cross:
            dismiss()
        case .arrow:
            popViewController(true)
        }
    }

    @objc func bgViewDidTap() {
        containerView?.endEditing(true)
        if tapBackgroundViewToDismiss {
            dismiss()
        }
    }

    // MARK: - UIApplicationDidChangeStatusBarOrientationNotification
    @objc func orientationDidChange() {
        containerView?.endEditing(true)
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.containerView?.alpha = 0
        }, completion: { _ in
            self.layoutContainerView()
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.containerView?.alpha = 1
            }, completion: nil)
        })
    }

    // MARK: - UIKeyboardWillShowNotification & UIKeyboardWillHideNotification
    @objc func keyboardWillShow(notification: Notification) {
        guard getCurrentTextInput(in: containerView!) != nil else { return }

        keyboardInfo = notification.userInfo as? [String: Any]
        adjustContainerViewOrigin()
    }

    @objc func keyboardWillHide(notification: Notification) {
        keyboardInfo = nil

        guard let keyboardInfo = notification.userInfo as? [String: Any] else { return }

        setAnimation(with: keyboardInfo, transform: CGAffineTransform.identity)
    }

    func adjustContainerViewOrigin() {
        guard let keyboardInfo = keyboardInfo else { return }
        guard let currentTextInput = getCurrentTextInput(in: containerView!) else { return }

        let lastTransform = containerView?.transform
        containerView?.transform = CGAffineTransform.identity

        let textFieldBottomY = currentTextInput.convert(.zero, to: containerViewController?.view).y + currentTextInput.bounds.height
        let keyboardHeight = (keyboardInfo[UIKeyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0

        var offsetY: CGFloat = 0
        guard let minY = containerView?.frame.minY else { return }
        if style == .bottomSheet {
            offsetY = keyboardHeight
        } else {
            let spacing: CGFloat = 5
            let height = containerViewController!.view.bounds.height - keyboardHeight - spacing
            offsetY = minY + containerView!.bounds.height - height
            if offsetY <= 0 { return }

            let statusBarHeight = UIApplication.shared.statusBarFrame.height

            if minY - offsetY < statusBarHeight {
                offsetY = minY - statusBarHeight
                if textFieldBottomY - offsetY > height {
                    offsetY = textFieldBottomY - height
                }
            }
        }

        containerView?.transform = lastTransform!

        setAnimation(with: keyboardInfo, transform: CGAffineTransform(translationX: 0, y: -offsetY))
    }

    func setAnimation(with keyboardInfo: [String: Any], transform: CGAffineTransform) {
        guard let duration = (keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return }
        guard let curve = (keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int) else { return }

        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
        UIView.setAnimationDuration(duration)

        containerView?.transform = transform

        UIView.commitAnimations()
    }

    func getCurrentTextInput(in view: UIView) -> UIView? {
        if view.conforms(to: UIKeyInput.self) && view.isFirstResponder {
            if let webBrowserClass = NSClassFromString("UIWebBrowserView"), let contentClass = NSClassFromString("WKContentView") {
                if view.isKind(of: webBrowserClass) || view.isKind(of: contentClass) {
                    return nil
                }
            }
            return view
        }

        for subview in view.subviews {
            let v = getCurrentTextInput(in: subview)
            if let v = v {
                return v
            }
        }

        return nil
    }

    // MARK: - STPopupFirstResponderDidChangeNotification
    @objc func firstResponderDidChange() {
        adjustContainerViewOrigin()
    }
}

extension STPopupController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}

extension STPopupController: UIViewControllerAnimatedTransitioning {
    func convert(_ transitioningContext: UIViewControllerContextTransitioning?) -> STPopupControllerTransitioningContext {
        var action: STPopupControllerTransitioningAction = .present
        if transitioningContext?.viewController(forKey: .to) != containerViewController {
            action = .dismiss
        }
        return STPopupControllerTransitioningContext(containerView: containerView!, action: action)
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        let context = convert(transitionContext)
        switch transitionStyle {
        case .slideVertical:
            return transitioningSlideVertical.popupControllerTransitionDuration(context)
        case .fade:
            return transitioningFade.popupControllerTransitionDuration(context)
        case .custom:
            return transitioning!.popupControllerTransitionDuration(context)
        }
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else { return }

        toVC.view.frame = fromVC.view.frame

        let topViewController = self.topViewController

        let context = convert(transitionContext)
        var transitioning: STPopupControllerTransitioning?
        switch transitionStyle {
        case .slideVertical:
            transitioning = transitioningSlideVertical
        case .fade:
            transitioning = transitioningFade
        case .custom:
            transitioning = self.transitioning
        }

        let duration = transitioning!.popupControllerTransitionDuration(context)
        if context.action == .present {
            fromVC.beginAppearanceTransition(false, animated: true)
            transitionContext.containerView.addSubview(toVC.view)

            topViewController?.beginAppearanceTransition(true, animated: true)
            toVC.addChildViewController(topViewController!)

            layoutContainerView()
            contentView?.addSubview(topViewController!.view)
            topViewController?.setNeedsStatusBarAppearanceUpdate()
            updateNavigationBar(animated: false)

            let lastBackgroundViewAlpha = backgroundView?.alpha ?? 0
            backgroundView?.alpha = 0
            backgroundView?.isUserInteractionEnabled = false
            containerView?.isUserInteractionEnabled = false
            containerView?.transform = CGAffineTransform.identity

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.backgroundView?.alpha = lastBackgroundViewAlpha
            }, completion: nil)

            transitioning?.popupControllerAnimateTransition(context, completion: {
                self.backgroundView?.isUserInteractionEnabled = true
                self.containerView?.isUserInteractionEnabled = true

                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                topViewController?.didMove(toParentViewController: toVC)
                fromVC.endAppearanceTransition()
            })
        } else {
            toVC.beginAppearanceTransition(true, animated: true)

            topViewController?.beginAppearanceTransition(false, animated: true)
            topViewController?.willMove(toParentViewController: nil)

            let lastBackgroundViewAlpha = backgroundView?.alpha
            backgroundView?.isUserInteractionEnabled = false
            containerView?.isUserInteractionEnabled = false

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                self.backgroundView?.alpha = 0
            }, completion: nil)

            transitioning?.popupControllerAnimateTransition(context, completion: {
                self.backgroundView?.isUserInteractionEnabled = true
                self.containerView?.isUserInteractionEnabled = true

                fromVC.view.removeFromSuperview()
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

                topViewController?.view.removeFromSuperview()
                topViewController?.removeFromParentViewController()

                toVC.endAppearanceTransition()

                self.backgroundView?.alpha = lastBackgroundViewAlpha!
            })
        }
    }
}

extension STPopupController: STPopupNavigationTouchEventDelegate {
    func popup(_ navigationBar: STPopupNavigationBar, touchDidMoveWith offset: CGFloat) {
        containerView?.endEditing(true)
        if style == .bottomSheet && offset < -STPopupBottomSheetExtraHeight {
            return
        }

        containerView?.transform = CGAffineTransform(translationX: 0, y: offset)
    }

    func popup(_ navigationBar: STPopupNavigationBar, touchDidEndWith offset: CGFloat) {
        if offset > dismissOffsetY {
            let transitionStyle = self.transitionStyle
            self.transitionStyle = .slideVertical
            dismiss() {
                self.transitionStyle = transitionStyle
            }
        } else {
            containerView?.endEditing(true)
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.containerView?.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}
