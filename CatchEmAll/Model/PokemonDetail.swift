//
//  PokemonDetail.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 11.11.2026.
//

struct PokemonDetail {
    struct Stats {
        let name: String
        let value: Int
    }
    
    let height: Double?
    let weight: Double?
    let stats: [Stats]
    let imageUrl: String?
}
