//
//  BaseRepositoryTest.swift
//  PersistanceKitTests
//
//  Created by Amir on 22/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import XCTest

@testable
import PersistanceWrapper

class BaseRepositoryTest: XCTestCase {
    var repository: BaseRepository<TestEntity>!
    
    override func setUp() {
        super.setUp()
        let fakeContext = CoreDataProvider().fakePersistentContainer.viewContext
        let dbManager = CoreDataManager(context: fakeContext)
        repository = BaseRepository<TestEntity>(dbManager: dbManager)
    }
    
    private func createDummyObject() {
        do {
            try repository.create(TestEntity.self) { object in
                XCTAssertNotNil(object)
            }
        } catch {
            print("failed creating object")
        }
    }
    
    func testCreate() throws {
        try repository.create(TestEntity.self) { object in
            XCTAssertNotNil(object)
        }
    }
    
    func testFetch() throws {
        createDummyObject()
        
        try repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { results in
            XCTAssertEqual(results.count, 1)
        })
        
    }

    func testUpdate() throws {
        createDummyObject()
        
        try repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] results in
            do {
                try self?.repository.update(object: results.first!)
                XCTAssertTrue(results.count > 0)
            } catch {}
        })

    }
    
    func testSave() throws {
        createDummyObject()
        
        try repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] results in
            do {
                try self?.repository.save(object: results.first!)
                XCTAssertTrue(results.count > 0)
            } catch {}
        })
    }
    
    func testDelete() throws {
        createDummyObject()
        
        try repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { [weak self] beforeResult in
            do {
                try self?.repository.delete(object: beforeResult.first!)
                
                try self?.repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { afterResult in
                    XCTAssertEqual(beforeResult.count - 1, afterResult.count)
                })
            } catch {}
        })
        
    }
    
    func testDeleteAll() throws {
        try repository.deleteAll(TestEntity.self)
        try repository.fetch(TestEntity.self, predicate: nil, sorted: nil, completion: { results in
            XCTAssertEqual(results.count, 0)
        })
    }
}
