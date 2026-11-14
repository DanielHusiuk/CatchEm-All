//
//  DetailViewModel.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import RxCocoa
import RxRelay

@MainActor
final class DetailViewModel {
    
    enum State {
        case loading, loaded(PokemonDetail), failed
    }
    
    private let id: Int
    private let api: ApiManager
    private let stateRelay = BehaviorRelay<State>(value: .loading)
    private var isLoading = false
    
    var state: Driver<State> { stateRelay.asDriver() }
    
    init(id: Int, api: ApiManager) {
        self.id = id
        self.api = api
    }
    
    func load() {
        guard !isLoading else { return }
        isLoading = true
        stateRelay.accept(.loading)
        
        Task {
            defer { isLoading = false }
            do {
                stateRelay.accept(.loaded(try await api.fetchDetail(id: id)))
            } catch {
                stateRelay.accept(.failed)
            }
        }
    }
}
