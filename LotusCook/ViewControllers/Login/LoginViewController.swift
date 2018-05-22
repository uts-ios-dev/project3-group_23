//
//  LoginViewController.swift
//  TaodaiAgents
//
//  Created by Zhuo Xiaoman  on 2018/4/3.
//  Copyright © 2018年 Mantis Group. All rights reserved.
//

import UIKit


class LoginViewController: MTBaseViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addTapToCloseEditing()

        #if DEBUG
            emailField.text = "aa@126.com"
            pwdField.text = "aaaa1111"
        #endif
        emailField.addTarget(self, action: #selector(checkLoginEnable), for: .editingChanged)
        pwdField.addTarget(self, action: #selector(checkLoginEnable), for: .editingChanged)
        
    }

    @IBAction func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func login() {
        guard let text = emailField.text, text.count > 0 else {
            return showMessage("please enter email")
        }
        
        guard let password = pwdField.text, password.count > 0 else {
            return showMessage("please enter password")
        }
        

        view.endEditing(true)
        
        if let user = User.getUserBy(text, pwd: password) {
            User.shared().setUserInfo((user.email!, user.name!, user.password!, user.diet!, user.service))
            AppDelegate.shared.loginSuccess()
        } else {
            showMessage("error email or password")
        }
    }


    @objc private func checkLoginEnable() {
        if let text = emailField.text, text.count > 0,
            let password = pwdField.text, password.count > 0 {
            
                loginButton.isEnabled = true
            
        } else {
            loginButton.isEnabled = false
        }
        
    }
}


extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            pwdField.becomeFirstResponder()
        }
        else if textField == pwdField {
            checkLoginEnable()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        checkLoginEnable()
        return true
    }

}


