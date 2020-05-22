//
//  HomeSplitViewController.swift
//  Zion
//
//  Created by Junhao Chen on 5/22/20.
//  Copyright © 2020 Rose-Hulman. All rights reserved.
//

import UIKit

class HomeSplitViewController : UISplitViewController,
UISplitViewControllerDelegate{
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.preferredDisplayMode = .allVisible
    }

    func splitViewController(
             _ splitViewController: UISplitViewController,
             collapseSecondary secondaryViewController: UIViewController,
             onto primaryViewController: UIViewController) -> Bool {
        // Return true to prevent UIKit from applying its default behavior
        return true
    }
}
