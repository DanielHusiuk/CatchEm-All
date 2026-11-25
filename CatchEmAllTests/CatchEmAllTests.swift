//
//  CatchEmAllTests.swift
//  CatchEmAllTests
//
//  Created by Daniel Husiuk on 10.11.2026.
//

import XCTest
import RxSwift
import RxCocoa
@testable import CatchEmAll

final class CatchEmAllTests: XCTestCase {

    @MainActor
    func testFetchListObjects_Success() async {
        let api = MockApiManager()
        api.pages = [[MockApiManager.firstAnimal], [MockApiManager.secondAnimal]]
        
        let viewModel = ListViewModel(api: api)
        let firstPage = expectation(description: "First page")
        let secondPage = expectation(description: "Second page")
        var ids: [Int] = []
        
        let subscription = viewModel.items.drive(onNext: { items in
            ids = items.map(\.id)
            if ids == [1] {
                firstPage.fulfill()
            }
            if ids == [1, 20] {
                secondPage.fulfill()
            }
        })
        defer { subscription.dispose() }
        
        viewModel.loadNextPage()
        await fulfillment(of: [firstPage], timeout: 3)
        XCTAssertEqual(api.pageCallCount, 1)
        
        viewModel.loadNextPage()
        await fulfillment(of: [secondPage], timeout: 3)
        XCTAssertEqual(ids, [1, 20])
        XCTAssertEqual(api.pageCallCount, 2)
    }
    
    @MainActor
    func testFetchListObjects_Failure() async {
        let api = MockApiManager()
        api.pageFailures = 1
        
        let viewModel = ListViewModel(api: api)
        let failed = expectation(description: "Failed state")
        let loaded = expectation(description: "Items is loaded")
        var ids: [Int] = []
        
        let statusSubscription = viewModel.status.drive(onNext: { status in
            if status == .failed {
                failed.fulfill()
            }
        })
        
        let itemsSubscription = viewModel.items.drive(onNext: { items in
            ids = items.map(\.id)
            if !ids.isEmpty {
                loaded.fulfill()
            }
        })
        
        defer {
            statusSubscription.dispose()
            itemsSubscription.dispose()
        }
        
        viewModel.loadNextPage()
        await fulfillment(of: [failed], timeout: 3)
        XCTAssertTrue(ids.isEmpty)
        
        viewModel.loadNextPage()
        await fulfillment(of: [loaded], timeout: 3)
        XCTAssertEqual(ids, [1, 20])
        XCTAssertEqual(api.pageCallCount, 2)
    }
    
    @MainActor
    func testFetchDetail_Success() async {
        let api = MockApiManager()
        let viewModel = DetailViewModel(id: 1, api: api)
        let loaded = expectation(description: "Details loaded")
        
        let subscription = viewModel.state.drive(onNext: { state in
            guard case .loaded(let detail) = state else { return }
            XCTAssertEqual(detail.height, 0.5)
            XCTAssertEqual(detail.weight, 8.0)
            XCTAssertEqual(detail.stats.first?.value, 50)
            loaded.fulfill()
        })
        defer { subscription.dispose() }
        
        viewModel.loadDetail()
        await fulfillment(of: [loaded], timeout: 3)
        XCTAssertEqual(api.detailIDCount, [1])
    }
    
    @MainActor
    func testFetchDetail_Failure() async {
        let api = MockApiManager()
        api.detailError = MockApiManager.MockError.requestFailde
        let viewModel = DetailViewModel(id: 20, api: api)
        let failed = expectation(description: "Load failed")
        
        let subscription = viewModel.state.drive(onNext: { state in
            if case .failed = state {
                failed.fulfill()
            }
        })
        defer { subscription.dispose() }
        
        viewModel.loadDetail()
        await fulfillment(of: [failed], timeout: 3)
        XCTAssertEqual(api.detailIDCount, [20])
    }

}
