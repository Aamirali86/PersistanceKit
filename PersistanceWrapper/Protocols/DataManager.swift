//
//  DataManager.swift
//  PersistanceWrapper
//
//  Created by Amir on 19/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

//MARK: - DataManager Protocol
protocol DataManager {
    func create<E: Storable>(_ model: E.Type, completion: @escaping ((E) -> Void)) throws
    func fetch<E: Storable>(_ model: E.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([E]) -> Void)) throws
    func save<E: Storable>(object: E) throws
    func update<E: Storable>(object: E) throws
    func delete<E: Storable>(object: E) throws
    func deleteAll<E: Storable>(_ model: E.Type) throws
}
