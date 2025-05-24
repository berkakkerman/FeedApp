//
//  UICollectionViewCell+.swift
//  FeedApp
//
//  Created by Berk Akkerman on 25.05.2025.
//

import UIKit.UICollectionViewCell

protocol ReusableView: AnyObject {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        String(describing: Self.self)
    }
}

extension UICollectionReusableView: ReusableView {}

extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_ cellType: T.Type) where T: ReusableView {
        register(cellType, forCellWithReuseIdentifier: cellType.reuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        for indexPath: IndexPath,
        cellType: T.Type = T.self
    ) -> T where T: ReusableView {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: cellType.reuseIdentifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Couldn't dequeue \(cellType) with identifier \(cellType.reuseIdentifier)")
        }
        return cell
    }
    
    func register<T: UICollectionReusableView>(
        _ viewType: T.Type,
        ofKind kind: String
    ) where T: ReusableView {
        register(viewType, forSupplementaryViewOfKind: kind, withReuseIdentifier: viewType.reuseIdentifier)
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        ofKind kind: String,
        for indexPath: IndexPath,
        viewType: T.Type = T.self
    ) -> T where T: ReusableView {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: viewType.reuseIdentifier,
            for: indexPath
        ) as? T
        else {
            fatalError("Couldn't dequeue supplementary view \(viewType) with identifier \(viewType.reuseIdentifier)")
        }
        return view
    }
}

extension UICollectionView {
    
    func makeDiffableDataSource<SectionType: Hashable, Cell: UICollectionViewCell & ConfigurableCell>(
        cellType: Cell.Type
    ) -> UICollectionViewDiffableDataSource<SectionType, Cell.Model> {
        register(Cell.self, forCellWithReuseIdentifier: String(describing: Cell.self))
        let ds = UICollectionViewDiffableDataSource<SectionType, Cell.Model>(
            collectionView: self
        ) { collectionView, indexPath, model in
            let cell: Cell = collectionView.dequeueReusableCell(for: indexPath)
            cell.configure(with: model)
            return cell
        }
        return ds
    }
}
