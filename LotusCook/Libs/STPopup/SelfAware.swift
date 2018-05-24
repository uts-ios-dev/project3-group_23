//
//  SelfAware.swift
//
//  Copyright © 2018年 Mantis Group. All rights reserved.
//

import Foundation
import UIKit

/// 定义 `protocol` SelfAware
///
///     /// 必须实现SelfAware协议, 重写awake方法
///     extension UIButton: SelfAware {
///         private static let _onceToken = UUID().uuidString
///
///         static func awake() {
///            DispatchQueue.once(token: _onceToken) {
///                replaceMethod(NSClassFromString("UIButton")!, #selector(setTitle(_:for:)), #selector(mt_setTitle(_:for:)))
///                replaceMethod(NSClassFromString("UIButton")!, #selector(setTitleColor(_:for:)), #selector(mt_setTitleColor(_:for:)))
///            }
///         }
///
///         private func mt_setTitle(_ title: String, for state: UIControlState) {
///              mt_setTitle(title, for: state) // 方法替换之后相当于调用系统的setTitle方法
///             // todo
///         }
///     }
///
public protocol SelfAware: class {
    static func awake()
}

/// 创建代理执行单例
class NothingToSeeHere {
    
    static func harmlessFunction() {
        let typeCount = Int(objc_getClassList(nil, 0))
        let types = UnsafeMutablePointer<AnyClass?>.allocate(capacity: typeCount)
        let autoreleasingTypes = AutoreleasingUnsafeMutablePointer<AnyClass>(types)
        objc_getClassList(autoreleasingTypes, Int32(typeCount)) //获取所有的类
        for index in 0 ..< typeCount { (types[index] as? SelfAware.Type)?.awake() } //如果该类实现了SelfAware协议，那么调用awake方法
        types.deallocate()
        
    }
}


/// Swizzling Selector replaceMethod
///
/// - Parameters:
///   - _class: 类名
///   - _originSelector: 类的函数
///   - _newSelector: 新函数
public func replaceMethod(_ _class: AnyClass, _ _originSelector: Selector, _ _newSelector: Selector) {
    let oriMethod = class_getInstanceMethod(_class, _originSelector)
    let newMethod = class_getInstanceMethod(_class, _newSelector)
    let isAddedMethod = class_addMethod(_class, _originSelector, method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))
    if isAddedMethod {
        class_replaceMethod(_class, _newSelector, method_getImplementation(oriMethod!), method_getTypeEncoding(oriMethod!))
    } else {
        method_exchangeImplementations(oriMethod!, newMethod!)
    }
}

/// 执行单例
extension UIApplication {
    private static let runOnce:Void = {
        //使用静态属性以保证只调用一次(该属性是个方法)
        NothingToSeeHere.harmlessFunction()
    }()
    
    open override var next: UIResponder?{
        UIApplication.runOnce
        return super.next
    }
}


