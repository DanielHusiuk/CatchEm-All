//
//  DetailViewModel.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import UIKit
import RxCocoa
import RxRelay

@MainActor
final class DetailViewModel {
    
    enum State {
        case loading, loaded(PokemonDetail), failed
    }
    
    private let id: Int
    private let api: ApiManagerProtocol
    private let stateRelay = BehaviorRelay<State>(value: .loading)
    private var isLoading = false
    
    private let imageRelay = BehaviorRelay<UIImage?>(value: nil)
    private var imageTask: Task<Void, Never>?
    
    var state: Driver<State> { stateRelay.asDriver() }
    var image: Driver<UIImage?> {
        imageRelay.asDriver()
    }
    
    init(id: Int, api: ApiManagerProtocol) {
        self.id = id
        self.api = api
    }
    
    deinit {
        imageTask?.cancel()
    }
    
    private func loadImage(from urlString: String) {
        imageTask?.cancel()
        imageTask = nil
        imageRelay.accept(nil)
        
        imageTask = Task { [weak self] in
            let image = await DataLoader.shared.loadImage(from: urlString)
            guard !Task.isCancelled,
                    let image else {
                return
            }
            self?.imageRelay.accept(image)
        }
    }
    
    func loadDetail() {
        guard !isLoading else { return }
        isLoading = true
        stateRelay.accept(.loading)
        
        Task { @MainActor in
            defer { isLoading = false }
            do {
                let detail = try await api.fetchDetail(id: id)
                stateRelay.accept(.loaded(detail))
                
                if let imageUrl = detail.imageUrl {
                    loadImage(from: imageUrl)
                }
            } catch {
                stateRelay.accept(.failed)
            }
        }
    }
}
