//
//  BackgroundImage.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit

final class BackgroundImage: UIView {
    
    private let imageView = UIImageView()
    private let imageColor: UIColor
    
    init(
        imageName: String = "",
        imageColor: UIColor = .tintColor,
    ) {
        self.imageColor = imageColor
        super.init(frame: .zero)
        setupImage(imageName: imageName)
    }
    
    required init?(coder: NSCoder) {
        self.imageColor = .tintColor
        super.init(coder: coder)
        setupImage(imageName: "")
    }
    
    private func setupImage(imageName: String) {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        imageView.image = UIImage(systemName: imageName)?
            .applyingSymbolConfiguration(.init(weight: .ultraLight))
        imageView.tintColor = imageColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
