
import UIKit

@IBDesignable
public extension UIView {
    // MARK: - Useful param to UIView in xib
    
    
    @IBInspectable public var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.masksToBounds = true
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable public var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
   
    @IBInspectable public var borderColor: UIColor? {
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}


public struct Shadow {
  
    var color : UIColor
   
    var offset : UIOffset

    var opacity : CGFloat
 
    var radius : CGFloat
    

    public init( color : UIColor = UIColor.clear, offset : UIOffset = UIOffset.zero, opacity : CGFloat = 0, radius : CGFloat = 0) {
        self.color = color
        self.offset = offset
        self.opacity = opacity
        self.radius = radius
    }
    // MARK: Statics
    
    /// None Shadow
    public static let None = Shadow()
    /// Light Shadow
    public static let Light = Shadow(color: UIColor.black, offset: UIOffset.zero, opacity: 0.3, radius: 1)
    /// Dark Shadow
    public static let Dark = Shadow(color: UIColor.black, offset: UIOffset(horizontal: 2, vertical: 2), opacity: 0.8, radius: 3)
}

//MARK: - Equatable

extension Shadow : Equatable {}


public func == (lhs: Shadow, rhs:Shadow) -> Bool
{
    return lhs.color == rhs.color && lhs.offset == rhs.offset && lhs.opacity == rhs.opacity && lhs.radius == rhs.radius
}

// MARK: - CustomDebugStringConvertible

extension Shadow : CustomDebugStringConvertible
{
    public var debugDescription : String { return "Shadow(offset: \(offset), opacity: \(opacity), radius: \(radius), color: \(color))" }
}



public extension UIView
{
    // MARK: - UIView Shadow
    
  
    @IBInspectable
    public var shadowColor : UIColor?
        {
        set { layer.shadowColor = newValue?.cgColor }
        get
        {
            if let shadowCgColor = layer.shadowColor
            {
                return UIColor(cgColor: shadowCgColor)
            }
            return nil
        }
    }
    
   
    @IBInspectable
    public var shadowOffset : CGSize
        {
        set { layer.shadowOffset = newValue }
        get { return layer.shadowOffset }
    }
    
  
    @IBInspectable
    public var shadowOpacity : CGFloat
        {
        set { layer.shadowOpacity = Float(newValue) }
        get { return CGFloat(layer.shadowOpacity) }
    }
    
    @IBInspectable
    public var shadowRadius : CGFloat
        {
        set { layer.shadowRadius = newValue }
        get { return layer.shadowRadius }
    }
    
    
    public var shadow : Shadow
        {
        set
        {
            shadowColor = newValue.color
            shadowOffset = CGSize(width: newValue.offset.horizontal, height: newValue.offset.vertical)
            shadowOpacity = newValue.opacity
            shadowRadius = newValue.radius
        }
        
        get
        {
            return Shadow(
                color: shadowColor ?? UIColor.clear,
                offset: UIOffset(horizontal: shadowOffset.width, vertical: shadowOffset.height),
                opacity: shadowOpacity,
                radius: shadowRadius)
        }
    }
    
  
    public func applyPlainShadow() {
        let layer = self.layer
        
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 4
    }
    

    public func applyCurvedShadow() {
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        let depth = CGFloat(11.0)
        let lessDepth = 0.8 * depth
        let curvyness = CGFloat(5)
        let radius = CGFloat(1)
        
        let path = UIBezierPath()
        
        // top left
        path.move(to: CGPoint(x: radius, y: height))
        
        // top right
        path.addLine(to: CGPoint(x: width - 2*radius, y: height))
        
        // bottom right + a little extra
        path.addLine(to: CGPoint(x: width - 2*radius, y: height + depth))
        
        // path to bottom left via curve
        path.addCurve(to: CGPoint(x: radius, y: height + depth),
                             controlPoint1: CGPoint(x: width - curvyness, y: height + lessDepth - curvyness),
                             controlPoint2: CGPoint(x: curvyness, y: height + lessDepth - curvyness))
        
        let layer = self.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = radius
        layer.shadowOffset = CGSize(width: 0, height: -3)
    }
    
  
    public func applyHoverShadow() {
        let size = self.bounds.size
        let width = size.width
        let height = size.height
        
        let ovalRect = CGRect(x: 5, y: height + 5, width: width - 10, height: 15)
        let path = UIBezierPath(roundedRect: ovalRect, cornerRadius: 10)
        
        let layer = self.layer
        layer.shadowPath = path.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowRadius = 5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

