//
//  CategoriesModel.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/4/24.
//

import Foundation


class CategoriesModel {
    let id: Int
       let name: String
       let items: [ItemModel]
    
    init(id: Int, name: String, items: [ItemModel]) {
        self.id = id
        self.name = name
        self.items = items
    }
}
