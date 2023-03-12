//
//  ViewModel.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/03/03.
//

import Foundation
import RxSwift


class ViewModel {
    let disposeBag = DisposeBag()
    private let tvNetwork: TVNetwork
    private let movieNetwork: MovieNetwork
    
    init() {
        let provider = NetworkProvider()
        movieNetwork = provider.makeMovieNetwork()
        tvNetwork = provider.makeTVNetwork()
    }
    
    struct Input {
        let tvTrigger: Observable<Void>
        let movieTrigger: Observable<Void>
    }
    
    struct Output {
        let tvList: Observable<[TV]>
        let movieResult: Observable<MovieResult>
    }
    
    func transform(input: Input) -> Output {
        
        //trigger -> 네트워크 -> Observable<T> -> VC 전달 -> VC에서 구독
        
        
//        tvTrigger -> Observable<Void> -> Observable<[TV]>
        
        let tvList = input.tvTrigger.flatMapLatest {[unowned self] _ -> Observable<[TV]> in
//            Observable<TVListModel> -> Observable<[TV]>
            return self.tvNetwork.getTopRatedList().map{ $0.results }
        }
        
        
        let movieResult = input.movieTrigger.flatMapLatest { [unowned self] _ -> Observable<MovieResult> in
            //combineLatest
            //Observable 1 ,2,  3 합쳐서 하나의 Observable로 바꾸고싶다면?
            return Observable.combineLatest(self.movieNetwork.getUpcomingList(), self.movieNetwork.getPoplarList(), self.movieNetwork.getNowPlayingList()) { upcoming, popular, nowPlaying -> MovieResult in
                 return MovieResult(upcoming: upcoming, popular: popular, nowPlaying: nowPlaying)
            }
            
        }
        
        return Output(tvList: tvList, movieResult: movieResult)

    }
}
