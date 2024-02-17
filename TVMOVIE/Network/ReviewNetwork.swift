//
//  ReviewNetwork.swift
//  TVMOVIE
//
//  Created by paytalab on 2/17/24.
//

import Foundation
import RxSwift

final class ReviewNetwork {
    private let network: Network<ReviewListModel>

    init(network : Network<ReviewListModel>){
        self.network = network
    }
    
    func getReviewList(id: Int, contentType: ContentType) -> Observable<ReviewListModel> {
        
        return network.getItemList(path: "/\(contentType.rawValue)/\(id)/reviews", isEnglish: true)
    }
}
