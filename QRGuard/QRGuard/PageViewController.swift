//
//  PageViewController.swift
//  QRGuard
//
//  Created by user149673 on 5/25/19.
//  Copyright © 2019 Ground Zero. All rights reserved.
//

import UIKit
import Pulley

class PageViewController: UIPageViewController {

    lazy var pages = [
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "subscribedChannelsTableViewController"),
        self.getMainViewController(),
        UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "myChannelsTableViewController")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        
        setViewControllers([pages[1]], direction: .forward, animated: true)
        // Do any additional setup after loading the view.
    }
    
    func getMainViewController() -> UIViewController {
        let main = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainViewController") as! ViewController
        let drawer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "publicKeyDisplayViewController") as! PublicKeyDisplayViewController
        let pulley = PulleyViewController(contentViewController: main, drawerViewController: drawer)
        pulley.backgroundDimmingOpacity = 0.0
        return pulley
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return pages[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else {
            return nil
        }
        return pages[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.navigationItem.title = self.viewControllers?[0].navigationItem.title
        self.navigationItem.rightBarButtonItem = self.viewControllers?[0].navigationItem.rightBarButtonItem
    }
    
}
