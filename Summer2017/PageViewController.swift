//
//  PageViewController.swift
//  Summer2017
//
//  Created by Hyunrae Kim on 5/30/17.
//  Copyright © 2017 CodingBois. All rights reserved.
//

import UIKit




class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate  {
    

    
    lazy var viewControllerList:[UIViewController] = {
    let sb = UIStoryboard(name: "Main", bundle: nil)
    let vc1 = sb.instantiateViewController(withIdentifier: "DailyViewController")
    let vc2 = sb.instantiateViewController(withIdentifier: "GroupViewController")
    let vc3 = sb.instantiateViewController(withIdentifier: "MonthViewController")
    let vc4 = sb.instantiateViewController(withIdentifier: "toDoList")
    let vc5 = sb.instantiateViewController(withIdentifier: "chatsViewController")
    
        return [vc5, vc2, vc1, vc3, vc4]
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        //Start with second page
        self.setViewControllers([viewControllerList[2]], direction: .forward, animated: true, completion: nil)
    
    }
    
    func toDailyPage() {
        setViewControllers([viewControllerList[2]], direction: .reverse, animated: true, completion: nil)

    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        let previousIndex = vcIndex - 1
        guard previousIndex >= 0 else {return nil}
        guard viewControllerList.count > previousIndex else {return nil}
        return viewControllerList[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vcIndex = viewControllerList.index(of: viewController) else {return nil}
        let nextIndex = vcIndex + 1
        guard viewControllerList.count != nextIndex else {return nil}
        guard viewControllerList.count > nextIndex else { return nil}
        
        return viewControllerList[nextIndex]
    }
    
}
