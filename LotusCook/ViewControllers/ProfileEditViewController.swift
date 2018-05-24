//
//  ProfileEditViewController.swift
//  LotusCook
//
//  Created by Luochun on 2018/5/20.
//  Copyright © 2018年 Elase. All rights reserved.
//

import UIKit

class ProfileEditViewController: MTBaseViewController {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var dietSeg: TTSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Eidt profile"
        
        addNavigationBarLeftButton(self)
        
        
        
        dietSeg.thumbGradientColors = [MTColor.main, MTColor.main.withAlphaComponent(0.4)]
        
        dietSeg.itemTitles = ["normal", "vegetarian"]
        dietSeg.didSelectItemWith = {(index, title) -> () in
            print("Selected item \(index)")
            
        }
        
        
        nameField.text = User.shared().name
        emailField.text = User.shared().email
        passwordField.text = User.shared().password
        if User.shared().diet! == "normal" {
            dietSeg.selectItemAt(index: 0)
        } else {
            dietSeg.selectItemAt(index: 1)
        }
    
    }

    
    @IBAction func save() {
        guard let name = nameField.text, name.count > 0 && name.count <= 8 else {
            return showMessage("name allow 1 - 8 chars")
        }
        guard let email = emailField.text, email.count > 0 else {
            return showMessage("email is empty")
        }
        guard let pwd = passwordField.text, pwd.count > 0 else {
            return showMessage("password is empty")
        }

        let user = User.shared()
        user.name = name
        user.email = email
        user.password = pwd
        user.diet = String(dietSeg.titleForItemAtIndex(dietSeg.currentIndex))
        
        user.update()
        navigationController?.popViewController(animated: true)
    }
    
    
}
