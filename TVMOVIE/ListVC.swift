//
//  ListVC.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2024/02/24.
//

import Foundation
import UIKit

final class ListVC: UIViewController {
    private let collectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
}
