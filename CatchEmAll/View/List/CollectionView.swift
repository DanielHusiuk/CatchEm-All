//
//  CollectionView.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit

final class CollectionView: UICollectionView {
        
    init() {
        super.init(frame: .zero, collectionViewLayout: CollectionView.makeLayout())
        setupCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func makeLayout() -> UICollectionViewLayout {
        let spacing: CGFloat = 16
        
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(100)
            ),
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(
            top: spacing,
            leading: spacing,
            bottom: spacing,
            trailing: spacing
        )
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupCollectionView() {
        register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseIdentifier)
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 26.0, *) {
            topEdgeEffect.style = .soft
        }
    }
}
