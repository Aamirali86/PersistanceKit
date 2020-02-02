//
//  BaseDataManager.swift
//  VistaJet
//
//  Created by Amir on 23/11/2018.
//  Copyright © 2018 VistaJet. All rights reserved.
//

import Foundation

class BaseRepository<E> {
    var dbManager : DataManager
    
    required init(dbManager : DataManager) {
        self.dbManager = dbManager
    }
    
    func create<T>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws where T : Storable {
        try dbManager.create(model, completion: completion)
    }
    
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([T]) -> Void)) throws {
        try dbManager.fetch(model, predicate: predicate, sorted: sorted, completion: completion)
    }
    
    func update<T: Storable>(object: T) throws {
        try dbManager.update(object: object)
    }
    
    func save<T: Storable>(object: T) throws {
        try dbManager.save(object: object)
    }
    
    func delete<T: Storable>(object: T) throws {
        try dbManager.delete(object: object)
    }
    
    func deleteAll<T>(_ model: T.Type) throws where T : Storable {
        try dbManager.deleteAll(model)
    }
    
}
