//
//  RealmMappableProtocol.swift
//  PersistanceWrapper
//
//  Created by Amir on 19/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import Foundation
import RealmSwift

//MARK: - MappableProtocol
protocol MappableProtocol {
    
    associatedtype PersistenceType: Storable
    
    //MARK: - Method
    func mapToPersistenceObject() -> PersistenceType
    static func mapFromPersistenceObject(_ object: PersistenceType) -> Self
    
}
