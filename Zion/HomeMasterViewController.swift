//
//  MasterViewController.swift
//  Zion
//
//  Created by Junhao Chen on 5/11/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit
import FeedKit
import Alamofire
import AlamofireImage
import FirebaseFirestore
import FirebaseAuth

class HomeMasterViewController: UITableViewController {

    var detailViewController: HomeDetailViewController? = nil
    var contentEntries = [ContentEntry]()
    let entryCellIdentifier = "EntryCell"
    var feedDocRef : DocumentReference!
    var feedListener : ListenerRegistration!
    
    var rssFeed: RSSFeed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Feed"
        
        
        
        
        navigationItem.leftBarButtonItem = editButtonItem
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? HomeDetailViewController
        }
    }

    fileprivate func startListening() {
        if(feedListener != nil){
            feedListener.remove()
        }
        feedListener = feedDocRef.addSnapshotListener({ (documentSnapshot, error) in
            if let error = error {
                print("Error getting feeds \(error)")
                return
            }
            if let documentSnapshot = documentSnapshot{
                self.contentEntries.removeAll()
                documentSnapshot.data()?.forEach({ (arg0) in
                    let (keyURLString, value) = arg0
                    let parser = FeedParser(URL: URL(string : keyURLString)!)
                    parser.parseAsync { [weak self] (result) in
                        guard let self = self else { return }
                        switch result {
                        case .success(let feed):
                            // Grab the parsed feed directly as an optional rss, atom or json feed object
                            self.rssFeed = feed.rssFeed
                            let feedProperty = value as! Dictionary<String,AnyObject>
                            if( feedProperty["type"] as! String == "news"){
                                self.rssFeed!.items?.forEach({ (rssFeedItem) in
                                    self.contentEntries.append(Article(withRSSFeedItem: rssFeedItem, fromRSSSource: keyURLString))
                                })
                            }else{
                                self.rssFeed!.items?.forEach({ (rssFeedItem) in
                                    self.contentEntries.append(Episode(withRSSFeedItem: rssFeedItem, fromRSSSource: keyURLString))
                                })
                            }
                            
                            // Then back to the Main thread to update the UI.
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                            
                        case .failure(let error):
                            print(error)
                        }
                    }
                })
                
            }
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        feedDocRef = Firestore.firestore().collection("ZionFeed").document(Auth.auth().currentUser!.uid)
        
        startListening()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        feedListener.remove()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                
                let object = contentEntries[indexPath.row]
                self.feedDocRef.getDocument { (document, error) in
                    if let error = error {
                        print("Retrieve feed url error \(error)")
                        return
                    }
                    
                    if let document = document{
                        var data = document.data()![object.source] as! Dictionary<String,AnyObject>
                        data["count"] = data["count"] as! Int + 1 as AnyObject
                        self.feedDocRef.setData([object.source: data], merge : true)
                    }
                }

                let controller = (segue.destination as! UINavigationController).topViewController as! HomeDetailViewController
                controller.entry = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                detailViewController = controller
            }
        }
    }

    // MARK: - Table View
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentEntries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : EntryCell = tableView.dequeueReusableCell(withIdentifier: entryCellIdentifier, for: indexPath) as! EntryCell
        cell.contentEntry = contentEntries[indexPath.row]
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contentEntries.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

}

// MARK: - Custom Cell
class EntryCell : UITableViewCell{
    @IBOutlet weak var titleTextView: UILabel!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var leftSuperViewContraint: NSLayoutConstraint!
    
    var contentEntry : ContentEntry!{
        didSet{
            self.previewImageView.image = nil
            fetchContent()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        leftSuperViewContraint.constant = 116
    }
    
    func fetchContent(){
        self.titleTextView!.text = contentEntry.getTitle()
        if let imgString = contentEntry.getiTunesImage(){
            if let imgUrl = URL(string: imgString) {
                previewImageView.af.setImage(withURL: imgUrl)
            }
        }else{
//            self.titleTextView.frame.origin.x = 0
            leftSuperViewContraint.constant = 16
        }
    }
    
}
