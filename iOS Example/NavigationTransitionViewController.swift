//
//  NavigationTransitionViewController.swift
//  Transition
//
//  Created by Konstantin Tsistjakov on 24/01/2017.
//  Copyright © 2017 Chipp Studio. All rights reserved.
//

import UIKit

class NavigationTransitionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func closeButtonAction(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
}
