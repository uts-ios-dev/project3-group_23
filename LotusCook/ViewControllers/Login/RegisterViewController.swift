//
//  RegisterViewController.swift
//  LotusCook
//
//  Created by Zhuo Xiaoman  on 2018/5/20.
//  Copyright © 2018年 Elase. All rights reserved.
//

import UIKit

class RegisterViewController: MTBaseViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var segment: TTSegmentedControl!
    
    @IBOutlet weak var steper: GMStepper!
    
    var diet: String = "normal"
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segment.thumbGradientColors = [MTColor.main, MTColor.main.withAlphaComponent(0.4)]
        
        segment.useShadow = true
        segment.itemTitles = ["normal", "vegetarian"]
        segment.didSelectItemWith = {(index, title) -> () in
            print("Selected item \(index)")
            
            self.diet = title!
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func signup(_ sender: UIButton) {
        guard let email = emailField.text, email.count > 0 else {
            return showMessage("email is empty")
        }
        guard let pwd = pwdField.text, pwd.count > 0 else {
            return showMessage("password is empty")
        }
        guard let confirm = confirmField.text, confirm.count > 0 else {
            return showMessage("confirm is empty")
        }
        guard let name = nameField.text, name.count > 0 && name.count <= 8 else {
            return showMessage("name allow 1 - 8 chars")
        }
        

        User.save(name, email: email, password: pwd, diet: diet, service: Int(steper.value))
        AppDelegate.shared.loginSuccess()
    }
    
    @IBAction func toSignin(_ sender: UIButton) {
        self.navigationController?.pushViewController(UIStoryboard.Scene.login, animated: true)
    }
    
}

extension RegisterViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == nameField, textField.text?.count == 8 {
            return false
        }
        
        return true
    }
}
