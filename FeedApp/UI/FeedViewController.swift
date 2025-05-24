//
//  FeedViewController.swift
//  FeedApp
//
//  Created by Berk Akkerman on 24.05.2025.
//

import UIKit

final class FeedViewController: UIViewController {
    
    private enum Section { case main }

    // MARK: UI

    private lazy var collectionView: UICollectionView = {
        let layout = makeLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refresh
        collectionView.register(NewPostsHeaderView.self, ofKind: UICollectionView.elementKindSectionHeader)
        return collectionView
    }()

    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Post> = {
      collectionView.makeDiffableDataSource(cellType: PostCell.self)
    }()

    // MARK: State

    private let viewModel = FeedViewModel()
    private var eventsTask: Task<Void, Never>?
    private var currentNewCount: Int = .zero

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupHeaderFooterProvider()
        bindViewModel()
        Task { await viewModel.loadInitial() }
    }
    
    private func setupHeaderFooterProvider() {
        dataSource.supplementaryViewProvider = { [weak self] cv, kind, ip in
            guard
                let self = self,
                kind == UICollectionView.elementKindSectionHeader,
                let header = cv.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: NewPostsHeaderView.reuseIdentifier,
                    for: ip
                ) as? NewPostsHeaderView
            else { return nil }
            header.set(
                target: self,
                action: #selector(self.didTapNewPosts),
                title: "^[New \(self.currentNewCount) post](inflect: true)",
                show: self.currentNewCount > .zero
            )
            return header
        }
    }
    
    private func setupUI() {
        title = "Feed"
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    deinit {
        eventsTask?.cancel()
    }

    // MARK: Bind

    private func bindViewModel() {
        eventsTask = Task {
            for await event in await viewModel.events() {
                handle(event)
            }
        }
    }

    @MainActor
    private func handle(_ event: FeedEvent) {
        
        switch event {
        case .postsUpdated(let posts):
            var snapshot = NSDiffableDataSourceSnapshot<Section, Post>()
            snapshot.appendSections([.main])
            snapshot.appendItems(posts, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
            
        case .loading(let isLoading):
            if isLoading {
                collectionView.refreshControl?.beginRefreshing()
            } else {
                collectionView.refreshControl?.endRefreshing()
            }
            
        case .newCount(let count):
            currentNewCount = count
            let snapshot = dataSource.snapshot()
            dataSource.apply(snapshot, animatingDifferences: false)
            
        case .error(let message):
            print("message")
        }
    }


    // MARK: Layout

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(260)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(260)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(40)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: Actions

    @objc private func didPullToRefresh() {
        Task { await viewModel.loadInitial() }
    }

    @objc private func didTapNewPosts() {
        Task { await viewModel.insertNew() }
    }
}

// MARK: - Pagination

extension FeedViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height    = scrollView.frame.size.height

        if offsetY > contentHeight - height - 200 {
            Task { await viewModel.loadMore() }
        }
    }
}
