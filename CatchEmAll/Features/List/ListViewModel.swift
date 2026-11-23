//
//  ListViewModel.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import RxCocoa

@MainActor
final class ListViewModel {
    
    enum Status {
        case idle, loading, failed
    }
    
    private let api: ApiManagerProtocol
    private let rows = BehaviorRelay<[CellModel]>(value: [])
    private let statusRelay = BehaviorRelay<Status>(value: .idle)
    
    var items: Driver<[CellModel]> { rows.asDriver() }
    var status: Driver<Status> { statusRelay.asDriver() }
    
    init(api: ApiManagerProtocol) {
        self.api = api
    }
    
    func makeDetailViewModel(id: Int) -> DetailViewModel {
        DetailViewModel(id: id, api: api)
    }
    
    func loadNextPage() {
        guard statusRelay.value != .loading,
              api.hasNextPage else {
            return
        }
        statusRelay.accept(.loading)
        
        Task {
            do {
                let newItems = try await api.fetchNextPage()
                rows.accept(rows.value + newItems)
                statusRelay.accept(.idle)
            } catch {
                statusRelay.accept(.failed)
            }
        }
        
    }
    
}
