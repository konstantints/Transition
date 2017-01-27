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
    
    // MARK: - Private
    fileprivate var underController: UIViewController!
    
    // MARK: - Override
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.underController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "underController")
        self.underController.transition = UnderTransition(animationDuration: 0.4)
        
        // Set gesture recognizer
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(sender:)))
        panGesture.delegate = self
        self.tableView.addGestureRecognizer(panGesture)
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
        return 2
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch indexPath {
        case IndexPath(row: 0, section: 0):
            cell.textLabel?.text = "Navigation transition"
        case IndexPath(row: 1, section: 0):
            cell.textLabel?.text = "Under transition"
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
        case IndexPath(row: 1, section: 0):
            self.present(self.underController, animated: true, completion: nil)
        default:
            print("No action")
        }
    }
    
    // MARK: - Pan gesture action
    fileprivate var transitionUpdate: CGFloat = 0.0
    func panGestureAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        self.transitionUpdate = translation.y / self.view.bounds.size.height
        print("\(self.transitionUpdate): Translation = \(translation.y)")
        
        switch sender.state {
        case .began:
            self.underController.transition!.beginInteractivePresentationTransition(from: self, completion: nil)
        case .changed:
            self.underController.transition!.updateInteractivePresentationTransition(_toProgress: self.transitionUpdate)
        default:
            if self.transitionUpdate > 0.5 {
                self.underController.transition!.finishInteractivePresentationTrasition()
            } else {
                self.underController.transition!.cancelInteractivePresentationTransaction()
            }
        }
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer is UIPanGestureRecognizer else {
            return false
        }
        let translation = (gestureRecognizer as! UIPanGestureRecognizer).translation(in: self.view)
        let offset = self.tableView.contentOffset
        let navBarHeight = self.navigationController!.navigationBar.frame.size.height
        let statusBarHeight: CGFloat = UIApplication.shared.isStatusBarHidden ? 0.0 : 20
        let fullHeight = navBarHeight + statusBarHeight
        
        if translation.y > 0 && -offset.y == fullHeight {
            return true
        }
        
        return false
    }
}
