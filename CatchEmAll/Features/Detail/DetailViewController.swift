//
//  DetailViewController.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit
import RxSwift
import RxCocoa

final class DetailViewController: UIViewController {
    
    private enum DetailSection: String, CaseIterable {
        case about = "About"
        case stats = "Stats"
        case evolution = "Evolution"
        case moves = "Moves"
    }
    
    private struct DetailRow {
        let name: String
        let value: String
    }
    
    private let item: CellModel
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    private var loadedDetail: PokemonDetail?
    private var imageTask: Task<Void, Never>?
    
    private let mainStackView = UIStackView()
    private let imageView = UIImageView()
    
    private let segmentedControl = UISegmentedControl(
        items: DetailSection.allCases.map(\.rawValue)
    )
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let tableRows = BehaviorRelay<[DetailRow]>(value: [])
    private let cellIdentifier = "DetailCell"
    private lazy var tableHeight = tableView.heightAnchor.constraint(equalToConstant: 0)
    
    private let infoLabel = UILabel()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let retryButton = UIButton(type: .system)
    
    init(item: CellModel, viewModel: DetailViewModel) {
        self.item = item
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        imageTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        title = item.title
        view.backgroundColor = .systemBackground
        setupLayout()
        
        viewModel.state
            .asDriver()
            .drive(onNext: { [weak self] state in
                guard let self else { return }
                renderView(state)
            })
            .disposed(by: disposeBag)
        
        segmentedControl.rx.selectedSegmentIndex.changed
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                renderSelectedSection()
            })
            .disposed(by: disposeBag)
        
        retryButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                viewModel.load()
            })
            .disposed(by: disposeBag)
        
        viewModel.load()
    }
    
    private func setupLayout() {
        imageView.contentMode = .scaleAspectFit
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.tintColor], for: .selected)
        retryButton.setTitle("Couldn't load data. Retry?", for: .normal)
        
        infoLabel.numberOfLines = 0
        infoLabel.font = .systemFont(ofSize: 16, weight: .regular)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.text = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 

Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.

Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. 

Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
"""
        
        contentStackView.axis = .vertical
        contentStackView.alignment = .center
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.alignment = .fill
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentStackView.addArrangedSubview(tableView)
        contentStackView.addArrangedSubview(infoLabel)
        scrollView.addSubview(contentStackView)
        
        mainStackView.addArrangedSubview(imageView)
        mainStackView.addArrangedSubview(segmentedControl)
        mainStackView.addArrangedSubview(scrollView)
        mainStackView.addArrangedSubview(loadingIndicator)
        mainStackView.addArrangedSubview(retryButton)
        
        view.addSubview(mainStackView)
        setupTableView()
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor.constraint(equalTo: contentStackView.widthAnchor),
            infoLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor, constant: -18),
            
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            tableHeight,
            
            mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 12),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupTableView() {
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = false
        tableView.allowsSelection = false
        tableView.isHidden = true
        
        tableView.rowHeight = 54
        tableView.estimatedRowHeight = 0
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableRows.bind(
            to: tableView.rx.items(
                cellIdentifier: cellIdentifier,
                cellType: UITableViewCell.self
            )) { _, row, cell in
                var content = UIListContentConfiguration.valueCell()
                content.text = row.name
                content.textProperties.font = .systemFont(ofSize: 16, weight: .semibold)
                content.secondaryText = row.value
                cell.contentConfiguration = content
                
                cell.backgroundConfiguration = .clear()
                cell.backgroundColor = .clear
                cell.contentView.backgroundColor = .clear
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Actions
    
    private func renderView(_ state: DetailViewModel.State) {
        imageTask?.cancel()
        imageTask = nil
        loadingIndicator.stopAnimating()
        retryButton.isHidden = true
        
        switch state {
        case .loading:
            loadingIndicator.startAnimating()
            
        case .failed:
            retryButton.isHidden = false
            
        case .loaded(let detail):
            loadedDetail = detail
            renderSelectedSection()
            imageView.image = UIImage(systemName: "photo")
            
            let imageUrl = detail.imageUrl ?? item.imageUrl
            imageTask = Task { [weak self] in
                let image = await DataLoader.shared.loadImage(from: imageUrl)
                guard !Task.isCancelled, let image else { return }
                self?.imageView.image = image
            }
        }
        
    }
    
    private func renderSelectedSection() {
        var rows: [DetailRow] = []
        let index = segmentedControl.selectedSegmentIndex
        guard let detail = loadedDetail,
              DetailSection.allCases.indices.contains(index) else { return }
        
        switch DetailSection.allCases[index] {
        case .about:
            rows = [
                DetailRow(
                    name: "Name",
                    value: item.title
                ),
                DetailRow(
                    name: "Number",
                    value: String(item.id)
                )
            ]
            
            if let height = detail.height {
                rows.append(
                    DetailRow(
                        name: "Height",
                        value: "\(height) m"
                    )
                )
            }
            if let weight = detail.weight {
                rows.append(
                    DetailRow(
                        name: "Weight",
                        value: "\(weight) kg"
                    )
                )
            }
            
        case .stats:
            rows = detail.stats.map { stat in
                DetailRow(
                    name: stat.name.replacingOccurrences(of: "-", with: " ").capitalized
                    , value: String(stat.value)
                )
            }
            
        case .evolution, .moves:
            break
        }
        
        tableHeight.constant = CGFloat(rows.count) * tableView.rowHeight
        tableView.isHidden = rows.isEmpty
        tableRows.accept(rows)
    }
    
}
