//
//  CoreDataManagerTests.swift
//  PersistanceWrapperTests
//
//  Created by Amir on 20/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import CoreData
import XCTest

@testable
import PersistanceWrapper

class CoreDataManagerTests: XCTestCase {
    
    var dbManager: DataManager!
    
    override func setUp() {
        super.setUp()
        let fakeContext = CoreDataProvider().fakePersistentContainer.viewContext
        dbManager = CoreDataManager(context: fakeContext)
        
        createDummyObject()
        createDummyObject()
        
        Thread.sleep(forTimeInterval: 2)
    }
    
    private func createDummyObject() {
        try! dbManager.create(TestEntity.self) { object in
            XCTAssertNotNil(object)
        }
    }
    
    func testErrorDescription() {
        do {
            try dbManager.create(RealmEntity.self) { object in }
        } catch let error {
            XCTAssertEqual("nilOrnotNSManagedObject", error.localizedDescription)
        }
    }
    
    func testCreate() {
        let expectation = self.expectation(description: "Creating")
        
        try! dbManager.create(TestEntity.self) { object in
            XCTAssertNotNil(object)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetch() {
        let expectation = self.expectation(description: "Fetching")
        
        try! dbManager.fetch(TestEntity.self, predicate: nil, sorted: Sorted(key: "id", ascending: true), completion: { results in
            XCTAssertNotEqual(results.count, 0)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testSave() {
        let expectation = self.expectation(description: "Savingn")
        
        try! dbManager.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] results in
            try! self?.dbManager.save(object: results.first!)
            
            XCTAssertTrue(results.count > 0)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdate() {
        let expectation = self.expectation(description: "Updating")
        
        try! dbManager.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] results in
            try! self?.dbManager.update(object: results.first!)
            
            XCTAssertTrue(results.count > 0)
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() {
        let expectation = self.expectation(description: "Deleting")

        try! dbManager.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] beforeResult in
            try! self?.dbManager.delete(object: beforeResult.first!)
            
            try! self?.dbManager.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { afterResult in
                XCTAssertEqual(beforeResult.count - 1, afterResult.count)
                
                expectation.fulfill()
            })
        })
        
        waitForExpectations(timeout: 3)
    }

    func testDeleteAll() {
        let expectation = self.expectation(description: "DeletingAll")

        try! dbManager.deleteAll(TestEntity.self)
        try! dbManager.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { results in
            XCTAssertEqual(results.count, 0)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 3)
    }
    
}
