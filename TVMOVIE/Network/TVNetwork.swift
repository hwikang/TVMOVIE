//
//  TVNetwork.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/02/28.
//

import Foundation
import RxSwift

final class TVNetwork {
    private let network: Network<TVListModel>

    init(network : Network<TVListModel>){
        self.network = network
    }
    
    func getTopRatedList(page: Int) -> Observable<TVListModel> {
        return network.getItemList(path: "/tv/top_rated", page: page)
    }
    
}
