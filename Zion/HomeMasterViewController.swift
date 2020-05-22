//
//  MasterViewController.swift
//  Zion
//
//  Created by Junhao Chen on 5/11/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit
import FeedKit

let feedURL = URL(string: "https://podcast.weareones.com/rss")!

class HomeMasterViewController: UITableViewController {

    var detailViewController: HomeDetailViewController? = nil
    var contentEntries = [ContentEntry]()
    let entryCellIdentifier = "EntryCell"

    let parser = FeedParser(URL: feedURL)
    
    var rssFeed: RSSFeed?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Feed"
        
        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let feed):
                // Grab the parsed feed directly as an optional rss, atom or json feed object
                self.rssFeed = feed.rssFeed
                
                self.rssFeed!.items?.forEach({ (rssFeedItem) in
                    self.contentEntries.append(ContentEntry(withRSSFeedItem: rssFeedItem))
                })
                
                // Or alternatively...
                //
                // switch feed {
                // case let .rss(feed): break
                // case let .atom(feed): break
                // case let .json(feed): break
                // }
                
                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
        
        navigationItem.leftBarButtonItem = editButtonItem

//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? HomeDetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

//    @objc
//    func insertNewObject(_ sender: Any) {
//        contentEntries.insert(Article(), at: 0)
//        let indexPath = IndexPath(row: 0, section: 0)
//        tableView.insertRows(at: [indexPath], with: .automatic)
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = contentEntries[indexPath.row]
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
        let object = contentEntries[indexPath.row]
        cell.titleTextView!.text = object.getTitle()
        if let imgString = object.getiTunesImage(){
            if let imgUrl = URL(string: imgString) {
                DispatchQueue.global().async { // Download in the background
                do {
                    let data = try Data(contentsOf: imgUrl)
                    DispatchQueue.main.async { // Then update on main thread
                        cell.previewImageView.image = UIImage(data: data)
                }
                } catch {
                    print("Error downloading image: \(error)")
                }
                }
            }
        }
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
    
    
}
