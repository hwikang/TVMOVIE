//
//  ReviewViewController.swift
//  TVMOVIE
//
//  Created by paytalab on 2/17/24.
//

import UIKit
import RxSwift
import Kingfisher

fileprivate enum Section {
    case list
}

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
    private var dataSource: UICollectionViewDiffableDataSource<Section, ReviewModel>?
    private let collectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .grouped)
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.register(ReviewCollectionViewCell.self, forCellWithReuseIdentifier: ReviewCollectionViewCell.id)

        return collectionView
    }()
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
        setUI()
        bindViewModel()
    }
    
    private func setUI() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        setDataSource()
    }
    
    private func bindViewModel() {
        
        let output = viewModel.transform(input: ReviewViewModel.Input())
        output.reviewResult
            .map { result in
                switch result {
                case .success(let reviewList):
                    return reviewList
                case .failure(let error):
                    print(error)
                    return []
                }
            }
            .bind { [weak self] reviewList in
                guard !reviewList.isEmpty else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, ReviewModel>()
                snapshot.appendSections([.list])
                snapshot.appendItems(reviewList, toSection: .list)
                self?.dataSource?.apply(snapshot, animatingDifferences: false)

            }.disposed(by: disposeBag)
    }
    
    private func setDataSource() {
        //디폴트 셀 사용시 사용이 어려움 -> 패스
        self.dataSource = UICollectionViewDiffableDataSource<Section, ReviewModel>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: ReviewModel) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.id, for: indexPath) as? ReviewCollectionViewCell
            var text: String
            if !item.author.name.isEmpty {
                text = item.author.name
            } else {
                text = item.author.username
            }
            
            cell?.configure(title: text, url: item.author.imageURL)
            return cell
        }

    }
}

final class ReviewCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewCollectionViewCell"
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .bold)
        return label
    }()
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        addSubview(titleLabel)
        
        image.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(8)
            make.top.equalToSuperview()
        }
    }
    
    public func configure(title: String, url: String) {
        titleLabel.text = title
        image.kf.setImage(with: URL(string: url))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
