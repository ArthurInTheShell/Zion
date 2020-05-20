//
//  DetailViewController.swift
//  Zion
//
//  Created by Junhao Chen on 5/11/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var detailDescriptionLabel: UILabel!


    func configureView() {
        // Update the user interface for the detail item.
        if let entry = entry{
            if let label = detailDescriptionLabel {
                label.text = entry.getTitle()
            }
        }
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureView()
    }

    var entry: ContentEntry? {
        didSet {
            // Update the view.
            configureView()
        }
    }


}

