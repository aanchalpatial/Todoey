//
//  Item.swift
//  Todoey
//
//  Created by Aanchal Patial on 15/06/19.
//  Copyright © 2019 AP. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    @objc dynamic var title = ""
    @objc dynamic var done = false
    @objc dynamic var dateCreated : Date?
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
