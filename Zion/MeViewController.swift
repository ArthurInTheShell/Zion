//
//  MeViewController.swift
//  Zion
//
//  Created by Yifei Li on 5/20/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let uid = Auth.auth().currentUser!.uid
        Firestore.firestore().collection("ZionFeed").document(uid).addSnapshotListener { (documentSnapshot, error) in
            if let documentSnapshot = documentSnapshot {
                if(documentSnapshot.data() != nil){
                    var sortedSnapshot = documentSnapshot.data()?.sorted(by: { (data1, data2) -> Bool in
                        let value1 = data1.value as! Dictionary<String, Any>
                        let value2 = data2.value as! Dictionary<String, Any>
                        return (value1["count"] as! Int) - (value2["count"] as! Int) > 0
                    })
                    
                    for i in 0..<3{
                        if sortedSnapshot?.count == 0{
                            self.topThreeSource[i].text = "NO DATA"
                            self.topThreeSource[i].textColor = .gray
                            continue
                        }
                        let info = sortedSnapshot?.removeFirst().value as! Dictionary<String, Any>
                        self.topThreeSource[i].text! = info["name"] as! String
                    }
                }
            }else{
                print(error!)
            }
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
