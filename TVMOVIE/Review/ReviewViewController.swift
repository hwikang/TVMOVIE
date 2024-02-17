//
//  ReviewViewController.swift
//  TVMOVIE
//
//  Created by paytalab on 2/17/24.
//

import UIKit
import RxSwift

final class ReviewViewModel {
    
    private let reviewNetwork: ReviewNetwork
    private let contentID: Int
    private let contentType: ContentType
    //https://api.themoviedb.org/3/movie/933131/reviews?api_key=8d4d29292f768393c47103c8312674f5
    init(contentID: Int, contentType: ContentType) {
        self.contentID = contentID
        self.contentType = contentType
        let provider = NetworkProvider()
        reviewNetwork = provider.makeReviewNetwork()
    }
    struct Input {
    }
    
    struct Output {
        let reviewResult: Observable<Result<[ReviewModel], Error>>
    }
    
    func transform(input: Input) -> Output {

        let reviewResult: Observable<Result<[ReviewModel], Error>> = reviewNetwork.getReviewList(id: contentID, contentType: contentType)
            .map { reviewResult in
            return .success(reviewResult.results)
        }.catch { error in
            return Observable.just(.failure(error))
        }
        return Output(reviewResult: reviewResult)

    }
}

final class ReviewViewController: UIViewController {
    private let disposeBag = DisposeBag()
    private let viewModel: ReviewViewModel
    init(contentID: Int, contentType: ContentType) {
        self.viewModel = ReviewViewModel(contentID: contentID, contentType: contentType)
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let output = viewModel.transform(input: ReviewViewModel.Input())
        output.reviewResult.bind { result in
            switch result {
            case .success(let reviewList):
                print(reviewList)
            case .failure(let error):
                print(error)
            }
        }.disposed(by: disposeBag)
    }
}
