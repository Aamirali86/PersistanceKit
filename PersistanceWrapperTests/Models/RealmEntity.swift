//
//  TestEntity.swift
//  PersistanceKitTests
//
//  Created by Amir on 21/06/2019.
//  Copyright © 2019 Venturedive. All rights reserved.
//

import RealmSwift

class RealmEntity: Object {
    @objc dynamic var id: Int = Int.random(in: 0..<Int.max)
    
    override class func primaryKey() -> String {
        return "id"
    }
}
