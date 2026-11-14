//
//  ListViewModel.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import Foundation
import PokemonAPI
import RxCocoa

@MainActor
final class ListViewModel {
    
    enum Status {
        case idle, loading, failed
    }
    
    private let api: ApiManager
    private var lastPage: PKMPagedObject<PKMPokemon>?
    private let rows = BehaviorRelay<[CellModel]>(value: [])
    private let statusRelay = BehaviorRelay<Status>(value: .idle)
    
    var items: Driver<[CellModel]> { rows.asDriver() }
    var status: Driver<Status> { statusRelay.asDriver() }
    
    init(api: ApiManager) {
        self.api = api
    }
    
    func loadNextPage() {
        guard statusRelay.value != .loading,
                lastPage?.hasNext != false
        else {
            return
        }
        statusRelay.accept(.loading)
        
        Task {
            do {
                let page = try await api.fetchPage(after: lastPage)
                let newItems = (page.results ?? []).compactMap { resource -> CellModel? in
                    guard let name = resource.name,
                          let url = URL(string: resource.url ?? ""),
                          let id = Int(url.lastPathComponent) else {
                        return nil
                    }
                    let sprites = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon"
                    
                return CellModel(
                    id: id,
                    imageUrl: "\(sprites)/\(id).png",
                    title: name.replacingOccurrences(of: "-", with: " ").capitalized,
                    subtitle: String(format: "#%03ld", id)
                )
                }
                
                lastPage = page
                rows.accept(rows.value + newItems)
                statusRelay.accept(.idle)
            } catch {
                statusRelay.accept(.failed)
            }
        }
        
     }
    
}
