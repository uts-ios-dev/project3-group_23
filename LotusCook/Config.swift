//
//  Config.swift
//  HealthBot
//
//  Created by Luochun on 2018/5/15.
//  Copyright © 2018年 SpiderMan. All rights reserved.
//

import Foundation
import UIKit


struct MTColor {
    static var main = UIColor(hex: 0xee452f)
    
    static var pageback = UIColor(hex: 0xF4F4F4)
    static var title111 = UIColor(red:0.07, green:0.07, blue:0.07, alpha:1.00)
    static var title333 = UIColor(hex: 0x333333)
    static var des666 = UIColor(hex: 0x666666)
    static var des999 = UIColor(hex: 0x999999)         //999999
    
}


// Tabbar safe bottom margin.
let kTabbarSafeBottomMargin: CGFloat = (UIDevice.isIphoneX ? 34.0 : 0.0)

struct pingFang_SC {
    static func bold(_ size: CGFloat = 15.0) -> UIFont {
        return UIFont.boldSystemFont(ofSize: size)
    }
    static func medium(_ size: CGFloat = 15.0) -> UIFont {
        return UIFont(name: "PingFang-SC-Medium", size: size)!
    }
    static func light(_ size: CGFloat = 15.0) -> UIFont {
        return UIFont(name: "PingFang-SC-Light", size: size)!
    }
    static func regular(_ size: CGFloat = 15.0) -> UIFont {
        return UIFont(name: "PingFang-SC-Regular", size: size)!
    }
    
}


public extension UIStoryboard {
    
    static var main: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    
    static var login: UIStoryboard {
        return UIStoryboard(name: "Login", bundle: nil)
    }
    
    
    public struct Scene {
        
        static var main: MealsViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "MealsViewController") as! MealsViewController
        }
        
        static var recipes: RecipesViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "RecipesViewController") as! RecipesViewController
        }
        
        static var shopping: ShoppingViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "ShoppingViewController") as! ShoppingViewController
        }
        
        static var mine: MineViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "MineViewController") as! MineViewController
        }
        
        static var userEdit: ProfileEditViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "ProfileEditViewController") as! ProfileEditViewController
        }
        static var recipeDetail: RecipeDetailViewController {
            return UIStoryboard.main.instantiateViewController(withIdentifier: "RecipeDetailViewController") as! RecipeDetailViewController
        }
        
        
        
        static var index: IndexViewController {
            return UIStoryboard.login.instantiateViewController(withIdentifier: "IndexViewController") as! IndexViewController
        }
        
        static var login: LoginViewController {
            return UIStoryboard.login.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        }
        
        static var register: RegisterViewController {
            return UIStoryboard.login.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        }
        
        
    }

}



public extension UIView {
    // MARK: - UIView Tap To Close Editing
    
    /// 给 UIView 添加点击关闭编辑
    public func addTapToCloseEditing() {
        let tapToHideKeyBoard = UITapGestureRecognizer(target: self, action: #selector(UIView.hideKeyboard))
        addGestureRecognizer(tapToHideKeyBoard)
    }
    
    /// 隐藏键盘结束编辑
    @objc public  func hideKeyboard() {
        endEditing(true)
    }
    

}


/// 取消任务Block
public typealias CancelableTask = (_ cancel: Bool) -> ()


/// 延迟执行事件
///
/// - Parameters:
///   - time: 延迟时间
///   - work: 执行事件
/// - Returns: 取消 see `CancelableTask`
@discardableResult
public func delay(_ time: TimeInterval, work: @escaping ()->()) -> CancelableTask? {
    
    var finalTask: CancelableTask?
    
    let cancelableTask: CancelableTask = { cancel in
        if cancel {
            finalTask = nil // key
        } else {
            DispatchQueue.main.async(execute: work)
        }
    }
    
    finalTask = cancelableTask
    
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
        if let task = finalTask {
            task(false)
        }
    }
    
    return finalTask
}


/// 取消执行
public func cancel(_ cancelableTask: CancelableTask?) {
    cancelableTask?(true)
}

public extension UIImage {
    
    /// 根据颜色生成图片
    ///
    /// - Parameter color: 颜色
    /// - Returns: 结果图片
    public static func image(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
}


extension UIColor {
    
    /// init method with RGB values from 0 to 255, instead of 0 to 1
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: a)
    }
    
    /// 初始化 hex: 0xf3832d3
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat(CGFloat((hex & 0xFF0000) >> 16)/255.0)
        let green = CGFloat(CGFloat((hex & 0x00FF00) >> 8)/255.0)
        let blue = CGFloat(CGFloat((hex & 0x0000FF) >> 0)/255.0)
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    
    /// 初始化
    ///
    /// - parameter hexString: 16进制字符串 #223442 0x435353
    /// - alpha: 透明度
    /// - return: 颜色
    public convenience init?(_ hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString.replacingOccurrences(of: "0x", with: "")
        formatted = formatted.replacingOccurrences(of: "#", with: "")
        if let hex = Int(formatted, radix: 16) {
            self.init(hex: hex, alpha: alpha)
        } else {
            return nil
        }
    }
    
    
    /// conveniense init
    ///
    /// - Parameter hexStr: 16进制字符串   如：#aabbcc
    public convenience init(_ hexStr: String) {
        var hex = hexStr.hasPrefix("#")
            ? String(hexStr.dropFirst())
            : hexStr
        guard hex.count == 3 || hex.count == 6
            else {
                self.init(white: 1.0, alpha: 0.0)
                return
        }
        if hex.count == 3 {
            for (index, char) in hex.enumerated() {
                hex.insert(char, at: hex.index(hex.startIndex, offsetBy: index * 2))
            }
        }
        
        self.init(
            red:   CGFloat((Int(hex, radix: 16)! >> 16) & 0xFF) / 255.0,
            green: CGFloat((Int(hex, radix: 16)! >> 8) & 0xFF) / 255.0,
            blue:  CGFloat((Int(hex, radix: 16)!) & 0xFF) / 255.0, alpha: 1.0)
    }
}


// MARK: - Properties
public extension Date {
    
    /// User’s current calendar.
    public var calendar: Calendar {
        return Calendar.current
    }
    
    /// Era.
    ///
    ///        Date().era -> 1
    ///
    public var era: Int {
        return Calendar.current.component(.era, from: self)
    }
    
    /// Quarter.
    ///
    ///        Date().quarter -> 3 // date in third quarter of the year.
    ///
    public var quarter: Int {
        let month = Double(Calendar.current.component(.month, from: self))
        let numberOfMonths = Double(Calendar.current.monthSymbols.count)
        let numberOfMonthsInQuarter = numberOfMonths / 4
        return Int(ceil(month/numberOfMonthsInQuarter))
    }
    
    /// Week of year.
    ///
    ///        Date().weekOfYear -> 2 // second week in the year.
    ///
    public var weekOfYear: Int {
        return Calendar.current.component(.weekOfYear, from: self)
    }
    
    /// Week of month.
    ///
    ///        Date().weekOfMonth -> 3 // date is in third week of the month.
    ///
    public var weekOfMonth: Int {
        return Calendar.current.component(.weekOfMonth, from: self)
    }
    
    /// Year.
    ///
    ///        Date().year -> 2017
    ///
    ///        var someDate = Date()
    ///        someDate.year = 2000 // sets someDate's year to 2000
    ///
    public var year: Int {
        get {
            return Calendar.current.component(.year, from: self)
        }
        set {
            guard newValue > 0 else { return }
            let currentYear = Calendar.current.component(.year, from: self)
            let yearsToAdd = newValue - currentYear
            if let date = Calendar.current.date(byAdding: .year, value: yearsToAdd, to: self) {
                self = date
            }
        }
    }
}

extension UIDevice {
    static var isIphoneX: Bool {
        var modelIdentifier = ""
        if isSimulator {
            modelIdentifier = ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
        } else {
            var size = 0
            sysctlbyname("hw.machine", nil, &size, nil, 0)
            var machine = [CChar](repeating: 0, count: size)
            sysctlbyname("hw.machine", &machine, &size, nil, 0)
            modelIdentifier = String(cString: machine)
        }
        
        return modelIdentifier == "iPhone10,3" || modelIdentifier == "iPhone10,6"
    }
    
    static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }
}
