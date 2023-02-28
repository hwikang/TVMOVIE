//
//  MovieNetwork.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/02/28.
//

import Foundation
import RxSwift

final class MovieNetwork {
    private let network: Network<MovieListModel>
    init(network : Network<MovieListModel>){
        self.network = network
    }
    
    func getNowPlayingList() -> Observable<MovieListModel> {
        return network.getItemList(path: "/movie/now_playing")
    }
    func getPoplarList() -> Observable<MovieListModel> {
        return network.getItemList(path: "/movie/popular")
    }
    func getUpcomingList() -> Observable<MovieListModel> {
        return network.getItemList(path: "/movie/upcoming")
    }
    
    
    
}
