//
//  Category.swift
//  Todoey
//
//  Created by Aanchal Patial on 15/06/19.
//  Copyright © 2019 AP. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object {
    @objc dynamic var name = ""
    let items = List<Item>()
}
