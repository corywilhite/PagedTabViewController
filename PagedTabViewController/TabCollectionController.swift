//
//  TabCollectionController.swift
//  PagedTabViewController
//
//  Created by Cory Wilhite on 8/12/16.
//  Copyright © 2016 Cory Wilhite. All rights reserved.
//

import UIKit

class TabCollectionViewCell: UICollectionViewCell {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    private lazy var titleLabel: UILabel = self.createTitleLabel()
    private lazy var subtitleLabel: UILabel = self.createTitleLabel()
    
    // MARK: - Lazy Load Helpers
    
    private func createTitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(14)
        contentView.addSubview(label)
        return label
    }
    
    private func createSubtitleLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.textAlignment = .Center
        contentView.addSubview(label)
        return label
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let _ = subtitle {
            subtitleLabel.frame = CGRect(
                x: 0,
                y: contentView.frame.midY,
                width: contentView.frame.width,
                height: contentView.frame.height / 2
            )
            
            titleLabel.frame = CGRect(
                x: 0,
                y: 0,
                width: contentView.frame.width,
                height: contentView.frame.height / 2
            )
            
        } else {
            titleLabel.frame = contentView.frame
        }
        
    }
    
}

class TabCollectionView: UICollectionView {
    
    var height: CGFloat = 50
    
    /// Collapses this view depending on whether or not
    /// any auto-layout constraints have been properly configured.
    ///
    /// a.k.a. don't set a hard height constraint and let this view
    /// provide the intrinsicContentSize
    var isFolded: Bool = false {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    required convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        self.init(frame: .zero, collectionViewLayout: layout)
        scrollEnabled = false
        allowsMultipleSelection = false
        backgroundColor = .whiteColor()
        
        registerClass(TabCollectionViewCell.self, forCellWithReuseIdentifier: String(TabCollectionViewCell))
    }
    
    override func intrinsicContentSize() -> CGSize {
        let contentSize = collectionViewLayout.collectionViewContentSize()
        return CGSize(width: contentSize.width, height: isFolded ? 0 : height)
    }
    
}

struct TabConfiguration {
    let title: String
    let subtitle: String?
}

class TabCollectionDelegate: NSObject, UICollectionViewDelegateFlowLayout {
    
    var didSelect: ((indexPath: NSIndexPath) -> Void)?
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        didSelect?(indexPath: indexPath)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let sectionInset = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAtIndex: indexPath.section)
        let itemSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAtIndex: indexPath.section)
        let lineSpacing = self.collectionView(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAtIndex: indexPath.section)
        
        guard let itemCount = collectionView.dataSource?.collectionView(collectionView, numberOfItemsInSection: indexPath.section) else { return .zero }
        
        let floatItemCount = CGFloat(itemCount)
        
        let modifiedItemSpacing = itemSpacing * (floatItemCount - 1)
        let width = ceil( (collectionView.bounds.width - sectionInset.left - sectionInset.right - modifiedItemSpacing) / floatItemCount )
        
        let height = (collectionView.bounds.height - sectionInset.top - sectionInset.bottom - (lineSpacing / 2))
        
        return CGSize(width: width, height: height)
    }
}

class TabCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    var configurations: [TabConfiguration]
    
    required init(configurations: [TabConfiguration]) {
        self.configurations = configurations
        super.init()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return configurations.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(TabCollectionViewCell), forIndexPath: indexPath) as! TabCollectionViewCell
        cell.backgroundColor = .lightGrayColor()
        cell.title = configurations[indexPath.item].title
        cell.subtitle = configurations[indexPath.item].subtitle
        return cell
    }
}
