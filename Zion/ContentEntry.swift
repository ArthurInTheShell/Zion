//
//  ContentEntry.swift
//  Zion
//
//  Created by Junhao Chen on 5/19/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import Foundation
import FeedKit

class ContentEntry {

    var item : RSSFeedItem
    
    init( withRSSFeedItem item :RSSFeedItem ) {
        self.item = item
    }

    
    func getTitle() -> String {
        return item.title!
    }
    
    func getDescription() -> String {
        return item.description!
    }
    
    func getiTunesImage() -> String?{
        let imgString = item.iTunes?.iTunesImage?.attributes?.href
        if let imgString = imgString{
            return imgString
        }
        return nil
    }
}
