//
//  ViewController.swift
//  iOS Example
//
//  Created by Konstantin Tsistjakov on 24/01/2017.
//  Copyright © 2017 Chipp Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlet, UI
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "navigationTransitionSegue":
            let controller = segue.destination
            controller.transition = NavigationTransition(animationDuration: 0.5)
        default:
            print("No segue")
        }
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell.textLabel?.text = "Navigation transition"
        default:
            cell.textLabel?.text = "No action"
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            self.performSegue(withIdentifier: "navigationTransitionSegue", sender: self)
        default:
            print("No action")
        }
    }

}
