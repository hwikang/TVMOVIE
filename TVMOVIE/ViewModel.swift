//
//  ViewModel.swift
//  TVMOVIE
//
//  Created by Dumveloper on 2023/03/03.
//

import Foundation
import RxSwift


class ViewModel {
    enum ContentType {
        case tv
        case movie
    }
    let disposeBag = DisposeBag()
    private let tvNetwork: TVNetwork
    private let movieNetwork: MovieNetwork
    public var currentContentType: ContentType = .tv
    private var currentTVList: [TV] = []
    init() {
        let provider = NetworkProvider()
        movieNetwork = provider.makeMovieNetwork()
        tvNetwork = provider.makeTVNetwork()
    }
    
    struct Input {
        let tvTrigger: Observable<Int>
        let movieTrigger: Observable<Void>
        let search: Observable<String>
    }
    
    struct Output {
        let tvList: Observable<[TV]>
        let movieResult: Observable<Result<MovieResult, Error>>
    }
    
    func transform(input: Input) -> Output {
        
        let tvList = Observable.combineLatest(input.search, input.tvTrigger).asObservable()
            .flatMapLatest { [unowned self] searchKeyword, page in
                currentContentType = .tv
                if page == 1 { currentTVList = [] }
                if searchKeyword.isEmpty {
                    return self.tvNetwork.getTopRatedList(page: page)
                } else {
                    return self.tvNetwork.getQueriedList(page: page, query: searchKeyword)
                }
            }
            .map{ $0.results }
            .map { tvList in
                self.currentTVList += tvList
                return self.currentTVList
            }
        
        let movieResult = input.movieTrigger.flatMapLatest { [unowned self] _ -> Observable<Result<MovieResult, Error>> in
            currentContentType = .movie
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
