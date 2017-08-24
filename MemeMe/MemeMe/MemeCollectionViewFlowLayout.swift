//
//  MemeCollectionViewFlowLayout.swift
//  MemeMe
//
//  Created by 근성가이 on 2017. 3. 4..
//  Copyright © 2017년 근성가이. All rights reserved.
//

import UIKit
import Photos

class MemeCollectionViewFlowLayout: UICollectionViewFlowLayout {
    //MARK: - Properties
    var cellCount = 0
    var offSetY: CGFloat = 0.0
    let cellSpacing: CGFloat = 1.0
    var cellsPerRow: Int {
        if UIApplication.shared.statusBarOrientation.isLandscape {
            return 7 //landScape
        } else {
            return 4 //portrait
        }
    }
    var cellWidth: CGFloat {
        return (collectionView!.bounds.width - CGFloat(cellsPerRow - 1) * cellSpacing) / CGFloat(cellsPerRow)     }
    var collectionViewHeight: CGFloat {
        return (cellWidth + cellSpacing) * CGFloat(ceil(Double(cellCount) / Double(cellsPerRow)))
    }
    var maxOffsetY: CGFloat {
        return collectionView!.contentSize.height - collectionView!.frame.size.height
    }
}

//MARK: - Method: Layout
extension MemeCollectionViewFlowLayout {
    override func prepare() {
        cellCount = collectionView!.numberOfItems(inSection: 0)
    }
    
    override var collectionViewContentSize : CGSize {
        return CGSize(width: collectionView!.bounds.width, height: collectionViewHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var elementsInRect = [UICollectionViewLayoutAttributes]()
        
        for index in 0..<cellCount {
            let rowIndex = index % Int(cellsPerRow)
            let row = index / Int(cellsPerRow)
            
            let x = (CGFloat(rowIndex) * cellSpacing) + (CGFloat(rowIndex) * cellWidth)
            let y = (CGFloat(row) * cellSpacing) + (CGFloat(row) * cellWidth)
            
            let cellFrame = CGRect(x: x, y: y, width: cellWidth, height: cellWidth)
            let indexPath = IndexPath(row: index, section: 0)
            let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attribute.frame = cellFrame
            elementsInRect.append(attribute)
        }
        
        return elementsInRect
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint { //스크롤 시 마다 contentOffset
        offSetY = proposedContentOffset.y / maxOffsetY
        
        return proposedContentOffset
    }
}

