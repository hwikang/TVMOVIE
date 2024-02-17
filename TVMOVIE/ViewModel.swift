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
        let movieResult: Observable<Result<MovieResult, Error>>
    }
    
    func transform(input: Input) -> Output {
        let tvList = input.tvTrigger.flatMapLatest {[unowned self] _ -> Observable<[TV]> in
            return self.tvNetwork.getTopRatedList().map{ $0.results }
        }
        
        let movieResult = input.movieTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<MovieResult, Error>> in

            return Observable.combineLatest(self.movieNetwork.getUpcomingList(), self.movieNetwork.getPoplarList(), self.movieNetwork.getNowPlayingList()) { upcoming, popular, nowPlaying -> Result<MovieResult, Error> in
                return .success(MovieResult(upcoming: upcoming, popular: popular, nowPlaying: nowPlaying))
            }.catch { error in
                print("Error")
                return Observable.just(.failure(error))
            }
            
        }
        
        return Output(tvList: tvList, movieResult: movieResult)

    }
}
