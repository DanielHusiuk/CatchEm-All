//
//  CatchEmAllUITests.swift
//  CatchEmAllUITests
//
//  Created by Daniel Husiuk on 10.11.2026.
//

import XCTest

final class CatchEmAllUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        
        XCTAssertTrue(
            app.collectionViews["collectionView"].waitForExistence(timeout: 2),
            "The main screen did not appear."
        )
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    @MainActor
    func testOpenSelectedPokemon() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        
        let collectionView = app.collectionViews["collectionView"]
        let bulbasaur = collectionView.cells.containing(.staticText, identifier: "Bulbasaur").firstMatch
        
        XCTAssertTrue(collectionView.exists)
        XCTAssertTrue(collectionView.cells["listCell"].exists)
        
        XCTAssertFalse(app.activityIndicators["loadingIndicator"].exists)
        XCTAssertFalse(app.buttons["retryButton"].exists)
        
        XCTAssertTrue(bulbasaur.waitForExistence(timeout: 5))
        XCTAssertTrue(bulbasaur.staticTexts["#001"].exists)
        bulbasaur.tap()
        
        let tableView = app.tables["tableView"]
        
        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
        XCTAssertTrue(tableView.cells["detailCell"].exists)
        
        XCTAssertTrue(app.navigationBars.staticTexts["Bulbasaur"].exists)
        XCTAssertTrue(app.images["imageView"].exists)
        
        let segmentedControl = app.segmentedControls["segmentedControl"]
        XCTAssertTrue(segmentedControl.exists)
        XCTAssertTrue(segmentedControl.buttons["Stats"].exists)
        segmentedControl.buttons["Stats"].tap()
        
        XCTAssertTrue(tableView.staticTexts["Attack"].waitForExistence(timeout: 3))
        XCTAssertTrue(tableView.staticTexts["30"].exists)
        
        segmentedControl.buttons["About"].tap()
        XCTAssertTrue(tableView.staticTexts["0.5 m"].waitForExistence(timeout: 3))
        
        segmentedControl.buttons["Moves"].tap()
        XCTAssertTrue(app.staticTexts["infoLabel"].exists)
        XCTAssertFalse(tableView.exists)
        
        XCTAssertFalse(app.activityIndicators["loadingIndicator"].exists)
        XCTAssertFalse(app.buttons["retryButton"].exists)
        
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(bulbasaur.waitForExistence(timeout: 3))
    }
    
    @MainActor
    func testRetryAfterLoadFail() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-failFirstPage"]
        app.launch()
        
        let retryButton = app.buttons["retryButton"]
        XCTAssertTrue(retryButton.waitForExistence(timeout: 5))
        retryButton.tap()
        
        let collectionView = app.collectionViews["collectionView"]
        XCTAssertTrue(collectionView.exists)
        XCTAssertTrue(collectionView.cells["listCell"].exists)
        
        XCTAssertTrue(collectionView.cells.staticTexts["Bulbasaur"].waitForExistence(timeout: 3))
        XCTAssertFalse(retryButton.exists)
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
