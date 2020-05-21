//
//  MeViewController.swift
//  Zion
//
//  Created by Yifei Li on 5/20/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit
import FirebaseAuth

class MeViewController: UIViewController{
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet var topThreeSource: [UILabel]!
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Me"
        if Auth.auth().currentUser != nil {
            emailLabel.text = Auth.auth().currentUser?.email
        }
    }
    
    @IBAction func pressedLogOut(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            let loginViewController = storyboard?.instantiateViewController(identifier: "loginViewController") as! LoginViewController
            self.view.window?.rootViewController = loginViewController
        }catch{
            print("Sign out error")
        }
    }
}
