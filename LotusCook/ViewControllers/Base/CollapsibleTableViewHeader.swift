
import UIKit


protocol CollapsibleTableViewHeaderDelegate {
    func toggleSection(_ header: CollapsibleTableViewHeader, section: Int)
}

class CollapsibleTableViewHeader: UITableViewHeaderFooterView {
    
    var delegate: CollapsibleTableViewHeaderDelegate?
    var section: Int = 0
    
    let dayLabel = UILabel()
    
    let arrowImageView = UIImageView(image: #imageLiteral(resourceName: "bills-下箭头"))
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = ""
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    let headerHeight: CGFloat = 55
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        // Content View
        contentView.backgroundColor = .clear
        
        let content = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width, height: headerHeight))
        content.backgroundColor = UIColor(hex: 0xE5E5E5)
        contentView.addSubview(content)
        dayLabel.frame = CGRect(x: 20, y: 0, width: 180, height: headerHeight)
        content.addSubview(dayLabel)
        dayLabel.textColor = MTColor.main
        dayLabel.font = pingFang_SC.regular(16)
    
        arrowImageView.frame = CGRect(x: UIScreen.main.bounds.size.width - 25 - 12, y: (headerHeight - 12) / 2, width: 12, height: 12)
        contentView.addSubview(arrowImageView)
        
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CollapsibleTableViewHeader.tapHeader(_:))))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    @objc func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader else {
            return
        }
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        arrowImageView.image = collapsed ? #imageLiteral(resourceName: "bills-下箭头"):  #imageLiteral(resourceName: "bills-上箭头")
        //arrowImageView.rotate(collapsed ? .pi : 0.0)
    }
    
}

extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

