//
//  CollectionViewCell.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit

final class CollectionViewCell: UICollectionViewCell {
    
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let imageView = UIImageView()
    
    private let titleStackView = UIStackView()
    private let mainStackView = UIStackView()
    
    private var imageTask: Task<Void, Never>?
    static let reuseIdentifier = "ListCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupTitleStackView()
        setupImageView()
        setupMainStackView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
        setupTitleLabel()
        setupSubtitleLabel()
        setupTitleStackView()
        setupImageView()
        setupMainStackView()
    }
    
    deinit {
        imageTask?.cancel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        
        imageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with model: CellModel, loader: DataLoaderProtocol) {
        imageTask?.cancel()
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        imageView.image = UIImage(systemName: "photo")
        
        imageTask = Task { [weak self] in
            let image = await loader.loadImage(from: model.imageUrl)
            guard !Task.isCancelled, let image else { return }
            self?.imageView.image = image
        }
    }
    
    // MARK: - Setup
    
    private func setupContentView() {
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        layer.shadowOpacity = 0.3
    }
    
    private func setupTitleLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.numberOfLines = 1
        titleLabel.textAlignment = .left
        titleLabel.textColor = .tintColor
        titleLabel.font = .systemFont(ofSize: 16, weight: .bold)
    }
    
    private func setupSubtitleLabel() {
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.minimumScaleFactor = 0.5
        subtitleLabel.numberOfLines = 1
        subtitleLabel.textAlignment = .left
        subtitleLabel.textColor = .systemGray
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .regular)
    }
    
    private func setupTitleStackView() {
        titleStackView.translatesAutoresizingMaskIntoConstraints = false
        titleStackView.axis = .vertical
        titleStackView.alignment = .fill
        titleStackView.spacing = 8
        titleStackView.clipsToBounds = false
        
        titleStackView.addArrangedSubview(titleLabel)
        titleStackView.addArrangedSubview(subtitleLabel)
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupMainStackView() {
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 6
        mainStackView.clipsToBounds = false
        
        mainStackView.addArrangedSubview(titleStackView)
        mainStackView.addArrangedSubview(imageView)
        contentView.addSubview(mainStackView)
        
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            imageView.widthAnchor.constraint(equalTo: mainStackView.widthAnchor, multiplier: 0.50),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
    }
}
