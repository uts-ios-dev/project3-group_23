//  Created by Luochun on 2017/2/12.
//  Copyright © 2017年 Mantis. All rights reserved.
//

import UIKit

class STPopupControllerTransitioningSlideVertical: STPopupControllerTransitioning {

    func popupControllerAnimateTransition(_ context: STPopupControllerTransitioningContext, completion: (() -> Void)?) {
        guard let containerView = context.containerView else { return }
        let duration = popupControllerTransitionDuration(context)
        if context.action == .present {
            containerView.transform = CGAffineTransform(translationX: 0, y: containerView.superview!.bounds.height - containerView.frame.minY)

            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                containerView.transform = CGAffineTransform.identity
            }, completion: { (_) in
                completion?()
            })
        } else {
            let lastTransform = containerView.transform
            containerView.transform = CGAffineTransform.identity
            let originY = containerView.frame.minY
            containerView.transform = lastTransform

            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
                containerView.transform = CGAffineTransform(translationX: 0, y: containerView.superview!.bounds.height - originY + containerView.frame.height)
            }, completion: { (_) in
                containerView.transform = CGAffineTransform.identity
                completion?()
            })
        }
    }
}
