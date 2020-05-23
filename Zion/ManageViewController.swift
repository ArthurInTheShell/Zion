//
//  ManageViewController.swift
//  Zion
//
//  Created by Yifei Li on 5/21/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit
import Firebase

class ManageViewController: UITableViewController{
    var cellIdentifier = "ManageViewCell"
    var feedList = [Feed]()
    var feedRef: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Your Feeds"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddFeedAlert))
        feedRef = Firestore.firestore().collection("ZionFeed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            feedRef.document(uid!).addSnapshotListener { (snapShot, error) in
                if let snapShot = snapShot{
                    if snapShot.data() != nil{
                        self.feedList.removeAll()
                        snapShot.data()!.forEach({ (data) in
                            let url = data.key
                            let info = data.value as! Dictionary<String, Any>
                            print(data)
                            self.feedList.append(Feed(url: url, name: info["name"] as! String, count: info["count"] as! Int, type: info["type"] as! String))
                        })
                        self.tableView.reloadData()
                    }
                }else{
                    print("Error on get feeds \(error!)")
                }
            }
        }
    }
    
    @objc func showAddFeedAlert(){
        let alertController = UIAlertController(title: "New Source", message: "Please enter the URL of RSS source", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "RSS Url"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Type: news/podcast"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Enter", style: .default, handler: { (action) in
            let urlTextField = alertController.textFields![0] as UITextField
            let nameTextField = alertController.textFields![1] as UITextField
            let typeTextField = alertController.textFields![2] as UITextField
            let uid = Auth.auth().currentUser!.uid
            let url = urlTextField.text!
            let name = nameTextField.text!
            let type = typeTextField.text!
            self.feedRef.document(uid).setData(["\(url)" : [
                "name": name, "count": 0], "type": type], merge: true)
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = feedList[indexPath.row].name
        cell.detailTextLabel?.text = feedList[indexPath.row].url
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let feedToDelete = feedList[indexPath.row]
            let uid = Auth.auth().currentUser!.uid
            print(feedToDelete.url)
            feedRef.document(uid).updateData([feedToDelete.url: FieldValue.delete()])
        }
    }
    
    
}
