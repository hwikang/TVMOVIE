//
//  ReviewViewController.swift
//  TVMOVIE
//
//  Created by paytalab on 2/17/24.
//

import UIKit

final class ReviewViewController: UIViewController {
    private let contentID: Int
    init(contentID: Int) {
        self.contentID = contentID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
