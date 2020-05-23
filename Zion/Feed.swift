//
//  Feed.swift
//  Zion
//
//  Created by Yifei Li on 5/22/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import Foundation


class Feed{
    var url: String
    var name: String
    var count: Int
    var type: String
    
    init(url:String, name: String, count: Int, type: String) {
        self.url = url
        self.name = name
        self.count = count
        self.type = type
    }
}
