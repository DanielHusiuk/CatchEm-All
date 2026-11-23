//
//  ListViewController.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 10.11.2026.
//

import UIKit
import RxSwift
import RxCocoa

class ListViewController: UIViewController {
    
    private let firstImage = BackgroundImage(
        imageName: "bolt.fill",
        imageColor: .tintColor
    )
    
    private let secondImage = BackgroundImage(
        imageName: "bolt",
        imageColor: .darkGray
    )
    
    private let imageWidth: CGFloat = 400
    private let imageHeight: CGFloat = 1000
    
    private let backgroundImageContainer = UIView()
    private let collectionView = CollectionView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let stackView = UIStackView()
    private let retryButton = UIButton(type: .system)
    private let disposeBag = DisposeBag()
    private let viewModel: ListViewModel
    
    init(viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundImageContainer()
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupBackgroundImageContainer() {
        backgroundImageContainer.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageContainer.transform = CGAffineTransform(scaleX: 1, y: 0.6)
            .rotated(by: 10 * .pi / 180)
        backgroundImageContainer.alpha = 0.6
        
        backgroundImageContainer.addSubview(firstImage)
        backgroundImageContainer.addSubview(secondImage)
        view.addSubview(backgroundImageContainer)
        
        NSLayoutConstraint.activate([
            backgroundImageContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 250),
            backgroundImageContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100),
            
            firstImage.widthAnchor.constraint(equalToConstant: imageWidth),
            firstImage.heightAnchor.constraint(equalToConstant: imageHeight),
            firstImage.centerXAnchor.constraint(equalTo: backgroundImageContainer.centerXAnchor),
            firstImage.centerYAnchor.constraint(equalTo: backgroundImageContainer.centerYAnchor),
            
            secondImage.widthAnchor.constraint(equalToConstant: imageWidth),
            secondImage.heightAnchor.constraint(equalToConstant: imageHeight),
            secondImage.centerXAnchor.constraint(equalTo: backgroundImageContainer.centerXAnchor, constant: -20),
            secondImage.centerYAnchor.constraint(equalTo: backgroundImageContainer.centerYAnchor, constant: -30)
        ])
    }
    
    private func setupView() {
        title = "Know Them All"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .secondarySystemBackground
        setContentScrollView(collectionView, for: .top)
        retryButton.setTitle("Couldn't load data. Retry?", for: .normal)
        
        stackView.addArrangedSubview(collectionView)
        stackView.addArrangedSubview(loadingIndicator)
        stackView.addArrangedSubview(retryButton)
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        bind()
        viewModel.loadNextPage()
    }
    
    // MARK: - Actions
    
    private func bind() {
        viewModel.items
            .drive(collectionView.rx.items(
                cellIdentifier: CollectionViewCell.reuseIdentifier,
                cellType: CollectionViewCell.self
            )) { _, model, cell in
                cell.configure(with: model, loader: DataLoader.shared)
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in
                guard let self else { return }
                collectionView.deselectItem(at: indexPath, animated: true)
                
                guard let navigation = navigationController,
                      navigation.topViewController === self,
                      let item: CellModel = try? collectionView.rx.model(at: indexPath)
                        else { return }
                
                let detailViewModel = viewModel.makeDetailViewModel(id: item.id)
                let detailController = DetailViewController(item: item, viewModel: detailViewModel)
                navigation.pushViewController(detailController, animated: true)
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .asDriver()
            .drive(onNext: { [weak self] event in
                guard let self else { return }
                let count = collectionView.numberOfItems(inSection: event.at.section)
                if event.at.item >= count - 4, retryButton.isHidden {
                    viewModel.loadNextPage()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.status
            .drive(onNext: { [weak self] status in
                guard let self else { return }
                if status == .loading {
                    loadingIndicator.startAnimating()
                } else {
                    loadingIndicator.stopAnimating()
                }
                retryButton.isHidden = status != .failed
            })
            .disposed(by: disposeBag)
        
        retryButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                viewModel.loadNextPage()
            })
            .disposed(by: disposeBag)
    }
    
}
