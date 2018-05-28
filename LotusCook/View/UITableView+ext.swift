//
//  UITableView+ext.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/25.
//  Copyright © 2018年 Elase. All rights reserved.
//

import Foundation
import  UIKit



public extension UITableView {
    /// default table cell indentifier  return "Cell"
    public static var defaultCellIdentifier: String {
        return "Cell"
    }
    
    /// Register NIB to table view. NIB name and cell reuse identifier can match for convenience.
    ///
    /// - Parameters:
    ///   - nibName: Name of the NIB.
    ///   - cellIdentifier: Name of the reusable cell identifier.
    ///   - bundleIdentifier: Name of the bundle identifier if not local.
    public func registerNib(nibName: String, cellIdentifier: String = defaultCellIdentifier, bundleIdentifier: String? = nil) {
        self.register(UINib(nibName: nibName,
                            bundle: bundleIdentifier != nil ? Bundle(identifier: bundleIdentifier!) : nil),
                      forCellReuseIdentifier: cellIdentifier)
    }
    
    /// Register NIB to table view. NIB name and cell reuse identifier can match for convenience.
    ///
    /// - Parameters:
    ///   - cellClass: Name of the NIB.
    ///   - cellIdentifier: Name of the reusable cell identifier.
    ///   - bundleIdentifier: Name of the bundle identifier if not local.
    public func registerNib(cellClass: AnyClass, cellIdentifier: String = defaultCellIdentifier, bundleIdentifier: String? = nil) {
        let identifier = String.className(cellClass)
        self.register(UINib(nibName: identifier,
                            bundle: bundleIdentifier != nil ? Bundle(identifier: bundleIdentifier!) : nil),
                      forCellReuseIdentifier: cellIdentifier)
    }
    
    /// Gets the reusable cell with default identifier name.
    ///
    /// - Parameter indexPath: The index path of the cell from the table.
    public subscript(indexPath: IndexPath) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: UITableView.defaultCellIdentifier, for: indexPath)
    }
    
    /// Gets the reusable cell with the specified identifier name.
    ///
    /// - Parameters:
    ///   - indexPath: The index path of the cell from the table.
    ///   - identifier: Name of the reusable cell identifier.
    public subscript(indexPath: IndexPath, identifier: String) -> UITableViewCell {
        return self.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
}


extension String {
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
}

