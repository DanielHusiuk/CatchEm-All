//
//  MockApiManager.swift
//  CatchEmAll
//
//  Created by Daniel Husiuk on 23.11.2026.
//

#if DEBUG
import Foundation

@MainActor
final class MockApiManager: ApiManagerProtocol {
    enum MockError: Error {
        case requestFailde
    }
    
    static let firstAnimal = CellModel(
        id: 1,
        imageUrl: "",
        title: "Bulbasaur",
        subtitle: "#001"
    )
    
    static let secondAnimal = CellModel(
        id: 20,
        imageUrl: "",
        title: "Pikachu",
        subtitle: "#020"
    )
    
    var pages: [[CellModel]] = [[firstAnimal, secondAnimal]]
    var pageFailures = 0
    var detailError: Error?
    
    var detail = PokemonDetail(
        height: 0.5,
        weight: 8.0,
        stats: [
        .init(name: "hp", value: 50),
        .init(name: "attack", value: 30)
    ],
        imageUrl: nil
    )
    
    private var nextPage = 0
    private(set) var pageCallCount = 0
    private(set) var detailIDCount: [Int] = []
    
    var hasNextPage: Bool {
        nextPage < pages.count
    }
    
    func fetchNextPage() async throws -> [CellModel] {
        pageCallCount += 1
        
        if pageFailures > 0 {
            pageFailures -= 1
            throw MockError.requestFailde
        }
        
        guard hasNextPage else { return [] }
        
        let items = pages[nextPage]
        nextPage += 1
        return items
    }
    
    func fetchDetail(id: Int) async throws -> PokemonDetail {
        detailIDCount.append(id)
        
        if let detailError {
            throw detailError
        }
        
        return detail
    }
}

#endif
