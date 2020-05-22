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

let feedURL = URL(string: "https://podcast.weareones.com/rss")!

class HomeMasterViewController: UITableViewController {

    var detailViewController: HomeDetailViewController? = nil
    var contentEntries = [ContentEntry]()
    let entryCellIdentifier = "EntryCell"
    let feedURLStrings = ["https://podcast.weareones.com/rss":"podcast",
                          "https://feeds.a.dj.com/rss/RSSWorldNews.xml":"news"]
//    var parser = FeedParser(URL: feedURL)
    
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

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        // Parse asynchronously, not to block the UI.
        feedURLStrings.forEach { (arg0) in
            
            let (keyURLString, type) = arg0
            let parser = FeedParser(URL: URL(string : keyURLString)!)
            parser.parseAsync { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let feed):
                    // Grab the parsed feed directly as an optional rss, atom or json feed object
                    self.rssFeed = feed.rssFeed
                    if( type == "news"){
                        self.rssFeed!.items?.forEach({ (rssFeedItem) in
                            self.contentEntries.append(Article(withRSSFeedItem: rssFeedItem))
                        })
                    }else{
                        self.rssFeed!.items?.forEach({ (rssFeedItem) in
                            self.contentEntries.append(Episode(withRSSFeedItem: rssFeedItem))
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
        }
        
    }

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
    
    var contentEntry : ContentEntry!{
        didSet{
            self.previewImageView.image = nil
            fetchContent()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func fetchContent(){
        self.titleTextView!.text = contentEntry.getTitle()
        if let imgString = contentEntry.getiTunesImage(){
            if let imgUrl = URL(string: imgString) {
                previewImageView.af.setImage(withURL: imgUrl)
//                DispatchQueue.global().async { // Download in the background
//                    do {
//                        let data = try Data(contentsOf: imgUrl)
//                        DispatchQueue.main.async { // Then update on main thread
//                            self.previewImageView.image = UIImage(data: data)
//                        }
//                    } catch {
//                        print("Error downloading image: \(error)")
//                    }
//                }
            }
        }
    }
    
}
