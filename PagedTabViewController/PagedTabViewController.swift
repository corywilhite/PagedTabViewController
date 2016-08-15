//
//  PagedTabViewController.swift
//  PagedTabViewController
//
//  Created by Cory Wilhite on 8/12/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

final class PagedTabViewController: UIViewController, UIScrollViewDelegate {
    
    private(set) var controllers: [Int: UIViewController] = [:]
    
    // MARK: - Initialization
    
    convenience init(viewControllers: [UIViewController]) {
        self.init()
        for index in 0.stride(to: viewControllers.count, by: 1) {
            
            let controller = viewControllers[index]
            
            controllers[index] = controller
            add(controller, at: index)
        }
    }
    
    func add(controller: UIViewController, at index: Int) {
        controllers[index] = controller
        
        add(childController: controller, to: controllerScrollView)
    }
    
    // MARK: - Properties
    
    lazy var tabCollectionDelegate: TabCollectionDelegate = self.createDelegate()
    lazy var tabCollectionDataSource: TabCollectionDataSource = TabCollectionDataSource(configurations: self.tabConfigurations())
    lazy var tabCollectionView: UICollectionView = self.createTabCollectionView(
        dataSource: self.tabCollectionDataSource,
        delegate: self.tabCollectionDelegate
    )
    lazy var controllerScrollView: UIScrollView = self.createControllerScrollView()
    
    // MARK: - Lazy Load Helpers
    
    private func tabConfigurations() -> [TabConfiguration] {
        return controllersInOrder().map { TabConfiguration(title: $0.title ?? "", subtitle: nil) }
    }
    
    private func createDelegate() -> TabCollectionDelegate {
        let delegate = TabCollectionDelegate()
        delegate.didSelect = didSelect
        return delegate
    }
    
    func didSelect(indexPath: NSIndexPath) -> Void {
        let newPoint = CGPoint(
            x: CGFloat(indexPath.item) * view.frame.width,
            y: 0
        )
        
        controllerScrollView.setContentOffset(newPoint, animated: true)
    }
    
    private func createTabCollectionView(dataSource dataSource: TabCollectionDataSource, delegate: TabCollectionDelegate) -> TabCollectionView {
        
        let collectionView = TabCollectionView()
        
        collectionView.dataSource = dataSource
        collectionView.delegate = delegate
        
        return collectionView
    }
    
    private func controllersInOrder() -> [UIViewController] {
        return controllers.keys.sort(<).flatMap { controllers[$0] }
    }
    
    private func createTabCollectionControllerContainer() -> UIView {
        let container = UIView(frame: .zero)
        container.backgroundColor = .clearColor()
        return container
    }
    
    private func createControllerScrollView() -> UIScrollView {
        
        let scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.backgroundColor = .greenColor()
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blackColor()
        view.addSubview(tabCollectionView)
        snapEdges(of: tabCollectionView, to: view)
        
        view.addSubview(controllerScrollView) // lay this view out manually in viewDidLayoutSubviews
        
        view.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        controllerScrollView.frame = CGRect(
            x: 0,
            y: tabCollectionView.frame.height,
            width: view.bounds.width,
            height: view.bounds.height - tabCollectionView.frame.height
        )
        
        
        // set the frame of each child view controller
        for index in 0.stride(to: controllers.values.count, by: 1) {
            
            controllers[index]?.view.frame = CGRect(
                x: CGFloat(index) * controllerScrollView.bounds.width ,
                y: 0,
                width: controllerScrollView.bounds.width,
                height: controllerScrollView.bounds.height
            )
        }
        
        controllerScrollView.contentSize = CGSize(
            width: CGFloat(controllers.values.count) * view.bounds.width,
            height: view.bounds.height - 100
        )
        
    }
    
    // MARK: - + UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
}

private extension UIViewController {
    
    func add(childController controller: UIViewController, to view: UIView) {
        addChildViewController(controller)
        view.addSubview(controller.view)
        controller.didMoveToParentViewController(self)
    }
}

func snapEdges(of view: UIView, to parentView: UIView) {
    
    view.translatesAutoresizingMaskIntoConstraints = false
    parentView.translatesAutoresizingMaskIntoConstraints = false
    
    let leading = NSLayoutConstraint(
        item: view,
        attribute: .Leading,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Leading,
        multiplier: 1.0,
        constant: 0
    )
    
    let top = NSLayoutConstraint(
        item: view,
        attribute: .Top,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Top,
        multiplier: 1.0,
        constant: 0
    )
    
    let trailing = NSLayoutConstraint(
        item: view,
        attribute: .Trailing,
        relatedBy: .Equal,
        toItem: parentView,
        attribute: .Trailing,
        multiplier: 1.0,
        constant: 0
    )
    
    parentView.addConstraints([leading, top, trailing])
}