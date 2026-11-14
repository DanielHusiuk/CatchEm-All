//
//  ApiManager.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

import PokemonAPI

@MainActor
protocol ApiManagerProtocol {
    func fetchPage(
        after page: PKMPagedObject<PKMPokemon>?
    ) async throws -> PKMPagedObject<PKMPokemon>
    
    func fetchDetail(id: Int) async throws -> PokemonDetail
}

final class ApiManager: ApiManagerProtocol {
    
    private let api = PokemonAPI()
    private var detailsDictionary: [Int: PokemonDetail] = [:]
    
    func fetchPage(
        after page: PKMPagedObject<PKMPokemon>?
    ) async throws -> PKMPagedObject<PKMPokemon> {
        
        let pagination: PaginationState<PKMPokemon> =
        page.map { .continuing($0, .next) } ?? .initial(pageLimit: 20)
        
        return try await api.pokemonService.fetchPokemonList(
            paginationState: pagination
        )
    }
    
    func fetchDetail(id: Int) async throws -> PokemonDetail {
        if let cached = detailsDictionary[id] { return cached }
        
        let pokemon = try await api.pokemonService.fetchPokemon(id)
        let stats = (pokemon.stats ?? []).compactMap { stat -> PokemonDetail.Stats? in
            guard let name = stat.stat?.name, let value = stat.baseStat else {
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
    
}
