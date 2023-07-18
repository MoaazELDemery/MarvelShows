//
//  CollectrionViewLayout.swift
//  MarvelShows
//
//  Created by M.Ibrahim on 18/07/2023.
//

import Foundation
import UIKit

class CollectionViewLayout {
    func collectionViewLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.itemSize = CGSize(width: self.view.frame.width/2.2, height: self.view.frame.width/1.8)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        collectionView!.collectionViewLayout = layout
    }
}
