//
//  ApiManager.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import Foundation
import PokemonAPI

@MainActor
protocol ApiManagerProtocol {
    var hasNextPage: Bool { get }
    func fetchNextPage() async throws -> [CellModel]
    func fetchDetail(id: Int) async throws -> PokemonDetail
}

final class ApiManager: ApiManagerProtocol {
    
    private let api: PokemonAPI
    private var lastPage: PKMPagedObject<PKMPokemon>?
    private var detailsDictionary: [Int: PokemonDetail] = [:]
    
    var hasNextPage: Bool { lastPage?.hasNext ?? true }
    
    init(api: PokemonAPI = PokemonAPI()) {
        self.api = api
    }
    
    func fetchNextPage() async throws -> [CellModel] {
        guard hasNextPage else { return [] }
        let pagination: PaginationState<PKMPokemon> =
        lastPage.map { .continuing($0, .next) } ?? .initial(pageLimit: 20)
        
        let page = try await api.pokemonService.fetchPokemonList(
            paginationState: pagination
        )
        
        let items = page.results?.compactMap(makeCellModel(from:)) ?? []
        lastPage = page
        return items
    }
    
    func fetchDetail(id: Int) async throws -> PokemonDetail {
        if let cached = detailsDictionary[id] { return cached }
        
        let pokemon = try await api.pokemonService.fetchPokemon(id)
        let stats = (pokemon.stats ?? []).compactMap { stat -> PokemonDetail.Stats? in
            guard let name = stat.stat?.name,
                  let value = stat.baseStat else {
                return nil
            }
            return PokemonDetail.Stats(name: name, value: value)
        }
        
        let detail = PokemonDetail(
            height: pokemon.height.map { Double($0) / 10 },
            weight: pokemon.weight.map { Double($0) / 10 },
            stats: stats,
            imageUrl: pokemon.sprites?.other?.officialArtwork?.frontDefault ?? pokemon.sprites?.frontDefault
        )
        
        detailsDictionary[id] = detail
        return detail
    }
    
    private func makeCellModel(from resource: PKMAPIResource<PKMPokemon>) -> CellModel? {
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
    
}
