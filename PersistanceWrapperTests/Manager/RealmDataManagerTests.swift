//
//  RealmDataManagerTests.swift
//  PersistanceKitTests
//
//  Created by Amir on 21/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift

@testable
import PersistanceWrapper

class RealmDataManagerTests: XCTestCase {
    
    var dbManager: DataManager!
    
    override func setUp() {
        let realm = try? Realm(configuration: Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm"))
        dbManager = RealmDataManager(realm: realm)
        
        createDummyObject()
        createDummyObject()
        
        Thread.sleep(forTimeInterval: 2)
    }
    
    private func createDummyObject() {
        try! dbManager.create(RealmEntity.self, completion: { object in
            XCTAssertNotNil(object)
        })
    }
    
    func testErrorDescription() {
        do {
            try dbManager.create(TestEntity.self, completion: {_ in })
        } catch let error {
            XCTAssertEqual("nilOrnotRealm", error.localizedDescription)
        }
    }
    
    func testCreate() {
        let exp = expectation(description: "Creating")
        
        try! dbManager.create(RealmEntity.self) { object in
            XCTAssertNotNil(object)
            
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetch() {
        let exp = expectation(description: "Fetching")
        
        try! dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { results in
            XCTAssert(results.count > 0)
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchSort() {
        let exp = expectation(description: "Test sort")
        
        try! dbManager.fetch(RealmEntity.self, predicate: nil, sorted: Sorted(key: "id", ascending: true), completion: { results in
            XCTAssert(results.first!.id < results.last!.id)
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testFetchPredicate() {
        let exp = expectation(description: "Test Predicate")
        
        let predicate: NSPredicate = NSPredicate(format: "id > %d", 1000)
        try! dbManager.fetch(RealmEntity.self, predicate: predicate, sorted: Sorted(key: "id", ascending: true), completion: { results in
            XCTAssert(results.filter { $0.id < 1000 }.count == 0)
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testSave() {
        let exp = expectation(description: "Saving")
        
        try! dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { [weak self] results in
            try! self?.dbManager.save(object: results.first!)
            XCTAssertTrue(results.count > 0)
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testUpdate() throws {
        let expectation = self.expectation(description: "Deleting")
        
        let object = RealmEntity()
        object.id = 1
        try dbManager.update(object: object)
        
        try dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { results in
            XCTAssertTrue(results.count > 0)
            
            expectation.fulfill()
        })
        
        waitForExpectations(timeout: 1)
    }
    
    func testDelete() throws {
        let expectation = self.expectation(description: "Deleting")
        var beforeResult: Int = 0
        var afterResult: Int?

        try dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { [weak self] beforeResults in
            beforeResult = beforeResults.count
            try! self?.dbManager.delete(object: beforeResults.first!)
            
            try! self?.dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { afterResults in
                afterResult = afterResults.count
                XCTAssertEqual(beforeResult - 1, afterResult)
                
                expectation.fulfill()
            })
        })
        
        waitForExpectations(timeout: 3)
    }
    
    func testDeleteAll() throws {
        let expectation = self.expectation(description: "DeletingAll")
        var result: Int?
        
        try dbManager.deleteAll(RealmEntity.self)
        try dbManager.fetch(RealmEntity.self, predicate: nil, sorted: nil, completion: { results in
            result = results.count
            expectation.fulfill()
        })

        waitForExpectations(timeout: 3)
        XCTAssertEqual(result, 0)
    }
}
