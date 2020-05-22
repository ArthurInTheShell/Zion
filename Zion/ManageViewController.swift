//
//  ManageViewController.swift
//  Zion
//
//  Created by Yifei Li on 5/21/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit

class ManageViewController: UITableViewController{
    var cellIdentifier = "ManageViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Your Feeds"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddFeedAlert))
    }
    
    
    
    @objc func showAddFeedAlert(){
        let alertController = UIAlertController(title: "New Source", message: "Please enter the URL of RSS source", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "RSS Url"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            
        }))
        present(alertController, animated: true, completion: nil)
    }

}
