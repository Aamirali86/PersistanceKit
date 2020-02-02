//
//  CoredataManager.swift
//  PersistanceWrapper
//
//  Created by Amir on 19/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataError: Error {
    case nilOrnotNSManagedObject
}

extension CoreDataError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nilOrnotNSManagedObject:
            return NSLocalizedString("nilOrnotNSManagedObject", comment: "Object is not NSManaged object model or object is nil")
        }
    }
}


//MARK: - DataManager Implementation
class CoreDataManager {
    //MARK: - Stored Properties
    
    var fetchFromBackground: Bool
    var context : NSManagedObjectContext
    
    init(fetchFromBackground: Bool = true, context : NSManagedObjectContext) {
        self.context = context
        self.fetchFromBackground = fetchFromBackground
    }
    
    private lazy var privateContext: NSManagedObjectContext = {
        let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateContext.undoManager = nil
        privateContext.parent = context
        return privateContext
    }()
    
}

extension CoreDataManager: DataManager {
    //MARK: - Methods
    
    /// Create and save coredata instance
    ///
    /// - Parameters:
    ///   - model: Data model that needs to store
    ///   - completion: A closure that will return the created object
    /// - Throws: throws error
    func create<E>(_ model: E.Type, completion: @escaping ((E) -> Void)) throws where E : Storable {
        guard model is NSManagedObject.Type else {
            throw CoreDataError.nilOrnotNSManagedObject
        }
        
        let result = NSEntityDescription.insertNewObject(forEntityName: String(describing: model.self), into: context)
        try self.saveContext()
        
        completion(result as! E)
    }
    
    /// Fetch the coredata objects
    ///
    /// - Parameters:
    ///   - model: Data model that needs to fetch
    ///   - predicate: Query to filter objects
    ///   - sorted: Sort the objects
    ///   - completion: A closure that will return the fetch objects
    /// - Throws: throws error
    func fetch<E>(_ model: E.Type, predicate: NSPredicate?, sorted: Sorted?, completion: @escaping (([E]) -> Void)) throws where E : Storable {
        
        guard let result = try fetchRecords(String(describing: E.self), predicate: predicate, sortDescriptor: sorted) as? [E] else { throw CoreDataError.nilOrnotNSManagedObject }
        completion(result)
    }
    
    /// Save the objects
    ///
    /// - Parameter object: Storable object to save
    /// - Throws: throws error
    func save<E>(object: E) throws where E : Storable {
        guard object is NSManagedObject else { throw CoreDataError.nilOrnotNSManagedObject }
        
        try self.saveContext()
    }
    
    /// Update the given object
    ///
    /// - Parameter object: Storable object to update
    /// - Throws: throws error
    func update<E>(object: E) throws where E : Storable {
        guard object is NSManagedObject else { throw CoreDataError.nilOrnotNSManagedObject }
        try self.saveContext()
    }
    
    /// Delete the given object
    ///
    /// - Parameter object: Storable object to delete
    /// - Throws: throws error
    func delete<E>(object: E) throws where E : Storable {
        guard let object = object as? NSManagedObject else { throw CoreDataError.nilOrnotNSManagedObject }
        deleteContext(object)
    }
    
    /// Delete the given objects
    ///
    /// - Parameter model: Storable objects to delete
    /// - Throws: throws error
    func deleteAll<E>(_ model: E.Type) throws where E : Storable {
        guard model is NSManagedObject.Type else { throw CoreDataError.nilOrnotNSManagedObject }
        guard let records = try fetchRecords(String(describing: E.self)) else { return }
        
        for record in records {
            deleteContext(record)
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() throws {
        if fetchFromBackground {
            if privateContext.hasChanges {
                try privateContext.save()
            }
        } else {
            if context.hasChanges {
                try context.save()
            }
        }
    }
    
    /// Deletes the core data object from database
    ///
    /// - Parameter object: Core data object
    private func deleteContext(_ object: NSManagedObject) {
        if fetchFromBackground {
            privateContext.delete(object)
        } else {
            context.delete(object)
        }
    }
    
    /// Fetch filtered and sorted records.
    ///
    /// - Parameters:
    ///   - entity: Name of the entity
    ///   - predicate: Format or query to filter the records
    ///   - sortDescriptor: Sort the fetched records
    /// - Returns: The storable records
    /// - Throws: Throws error
    private func fetchRecords(_ entity : String, predicate : NSPredicate? = nil, sortDescriptor: Sorted? = nil) throws -> [NSManagedObject]? {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        //set the predicate
        fetchRequest.predicate = predicate

        if let sort = sortDescriptor {
            //set sort descriptor
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sort.key, ascending: sort.ascending)]
        }
        
        if fetchFromBackground {
            return try privateContext.fetch(fetchRequest) as? [NSManagedObject]
        }
        
        return try context.fetch(fetchRequest) as? [NSManagedObject]
    }
    
}
