//
//  RealmDataManager.swift
//  PersistanceWrapper
//
//  Created by Amir on 19/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import RealmSwift

enum RealmError: Error {
    case nilOrnotRealm
}

extension RealmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nilOrnotRealm:
            return NSLocalizedString("nilOrnotRealm", comment: "Object is not realm model or object is nil")
        }
    }
}

//MARK: - DataManager Implementation

class RealmDataManager {
    //MARK: - Stored Properties
    
    private let realm: Realm?
    private let queue: DispatchQueue?
    
    init(_ queue: DispatchQueue? = DispatchQueue.main, realm: Realm?) {
        self.realm = realm
        self.queue = queue
    }
}

extension RealmDataManager: DataManager {
    //MARK: - Methods
    
    /// Create and save realm instance
    ///
    /// - Parameters:
    ///   - model: Data model that needs to store
    ///   - completion: A closure that will return the created object
    /// - Throws: throws error
    func create<E>(_ model: E.Type, completion: @escaping ((E) -> Void)) throws where E : Storable {
        guard let realm = realm, let model = model as? Object.Type else { throw RealmError.nilOrnotRealm }
        try realm.write {
            let newObject = realm.create(model, value: [], update: .error) as! E
            completion(newObject)
        }
    }
    
    /// Fetch the relam objects
    ///
    /// - Parameters:
    ///   - model: Data model that needs to fetch
    ///   - predicate: Query to filter objects
    ///   - sorted: Sort the objects
    ///   - completion: A closure that will return the fetch objects
    /// - Throws: throws error
    func fetch<E>(_ model: E.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([E]) -> Void)) throws where E : Storable {
        
        queue?.async { [weak self] in
            autoreleasepool {
                guard let realm = self?.realm, let model = model as? Object.Type else { return }
                
                var objects = realm.objects(model)
                if let predicate = predicate {
                    objects = objects.filter(predicate)
                }
                if let sorted = sorted {
                    objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
                }
                
                completion(objects.compactMap { $0 as? E })
            }
        }

    }
    
    /// Save the objects
    ///
    /// - Parameter object: Storable object to save
    /// - Throws: throws error
    func save<E>(object: E) throws where E : Storable {
        guard let realm = realm, let object = object as? Object else { throw RealmError.nilOrnotRealm }
    
        queue?.async {
            try? realm.write {
                realm.add(object)
            }
        }
    }
    
    /// Update the given object
    ///
    /// - Parameter object: Storable object to update
    /// - Throws: throws error
    func update<E>(object: E) throws where E : Storable {
        guard let realm = realm, let object = object as? Object else { throw RealmError.nilOrnotRealm }
        
        queue?.async {
            try? realm.write {
                realm.add(object, update: .all)
            }
        }
    }
    
    /// Delete the given object
    ///
    /// - Parameter object: Storable object to delete
    /// - Throws: throws error
    func delete<E>(object: E) throws where E : Storable {
        guard let realm = realm, let object = object as? Object else { throw RealmError.nilOrnotRealm }
        
        queue?.async {
            try? realm.write {
                realm.delete(object)
            }
        }
    }
    
    /// Delete the given objects
    ///
    /// - Parameter model: Storable objects to delete
    /// - Throws: throws error
    func deleteAll<E>(_ model: E.Type) throws where E : Storable {
        guard let realm = realm, let model = model as? Object.Type else { throw RealmError.nilOrnotRealm }
        
        queue?.async {
            try? realm.write {
                let objects = realm.objects(model)
                for object in objects {
                    realm.delete(object)
                }
            }
        }
    }
    
}
