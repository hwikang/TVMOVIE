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

fileprivate enum ListItem: Hashable {
    case header(ReviewHeader)
    case content(Review)
}
fileprivate struct ReviewHeader: Hashable {
    let id: String
    let name: String
    let url : String
}
fileprivate struct Review: Hashable {
    let content: String
}
final class ReviewViewModel {
    
    private let reviewNetwork: ReviewNetwork
    private let contentID: Int
    private let contentType: ContentType
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
    private var dataSource: UICollectionViewDiffableDataSource<Section, ListItem>?
    private let collectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let listLayout = UICollectionViewCompositionalLayout.list(using: config)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: listLayout)
        collectionView.register(ReviewHeaderCollectionViewCell.self, forCellWithReuseIdentifier: ReviewHeaderCollectionViewCell.id)
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
        collectionView.rx.itemSelected.bind { [weak self] indexPath in
            guard let item = self?.dataSource?.itemIdentifier(for: indexPath),
                    var sectionSnapshot = self?.dataSource?.snapshot(for: .list) else { return }

            if case .header = item {
                if sectionSnapshot.isExpanded(item) {
                    sectionSnapshot.collapse([item])
                } else {
                    sectionSnapshot.expand([item])
                }
            }
            self?.dataSource?.apply(sectionSnapshot, to: .list)
        }.disposed(by: disposeBag)
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
               
                var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<ListItem>()
                reviewList.forEach { review in
                    var name = review.author.name.isEmpty ? review.author.username : review.author.name
                    let header = ReviewHeader(id: review.id, name: name, url: review.author.imageURL)
                    let headerListItem = ListItem.header(header)
                    
                    sectionSnapshot.append([headerListItem])
                    sectionSnapshot.append([.content(Review(content: review.content))], to: headerListItem)
                    
                }
                self?.dataSource?.apply(sectionSnapshot, to: .list)

            }.disposed(by: disposeBag)
    }
    
    private func setDataSource() {
        //디폴트 셀 사용시 사용이 어려움 -> 패스
        self.dataSource = UICollectionViewDiffableDataSource<Section, ListItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: ListItem) -> UICollectionViewCell? in
            switch item {
            case .header(let header):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewHeaderCollectionViewCell.id, for: indexPath) as? ReviewHeaderCollectionViewCell
                cell?.configure(title: header.name, url: header.url)
                return cell
            case .content(let content):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReviewCollectionViewCell.id, for: indexPath) as? ReviewCollectionViewCell
                cell?.configure(content: content.content)
                return cell
            }
        }
        var dataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, ListItem>()
        dataSourceSnapshot.appendSections([.list])
        dataSource?.apply(dataSourceSnapshot)
    }
}

final class ReviewHeaderCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewHeaderCollectionViewCell"
    private let image: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .regular)
        return label
    }()
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(image)
        addSubview(titleLabel)
        snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        image.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(image.snp.trailing).offset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    public func configure(title: String, url: String) {
        titleLabel.text = title
        if url.isEmpty {
            image.image = UIImage(systemName: "person.fill")
        } else {
            image.kf.setImage(with: URL(string: url))

        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

final class ReviewCollectionViewCell: UICollectionViewCell {
    static let id = "ReviewCollectionViewCell"
   
    let contentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(contentLabel)
        
        contentLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(20)
            make.leading.trailing.equalToSuperview().inset(14)
        }
    }
    
    public func configure(content: String) {
        contentLabel.text = content
       
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
