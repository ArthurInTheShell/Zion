//
//  LoginViewController.swift
//  Zion
//
//  Created by Yifei Li on 5/19/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class LoginViewController: UIViewController{
    var MainTabControllerIdentifier = "mainTabController"
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.placeholder = "Email"
        passwordTextField.placeholder = "Password"
        errorMessageLabel.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil{
            let mainTabViewController = storyboard?.instantiateViewController(identifier: MainTabControllerIdentifier) as! UITabBarController
            self.view.window?.rootViewController = mainTabViewController
        }
    }
    
    @IBAction func pressedCreateAccount(_ sender: Any) {
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if let error = error {
                print("Error Creating new User for Email/Password \(error)")
                self.errorMessageLabel.text = error.localizedDescription
                self.errorMessageLabel.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.errorMessageLabel.isHidden = true
                }
                return
            }
            let mainTabViewController = self.storyboard?.instantiateViewController(identifier: self.MainTabControllerIdentifier) as! UITabBarController
            self.view.window?.rootViewController = mainTabViewController
        }
    }
    
    @IBAction func pressedLogIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
            if let error = error {
                print("Error Sign in User for Email/Password \(error)")
                self.errorMessageLabel.text = error.localizedDescription
                               self.errorMessageLabel.isHidden = false
                               DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                   self.errorMessageLabel.isHidden = true
                               }
                return
            }
            let mainTabViewController = self.storyboard?.instantiateViewController(identifier: self.MainTabControllerIdentifier) as! UITabBarController
            self.view.window?.rootViewController = mainTabViewController
        }
    }
}
