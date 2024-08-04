//
//  ItemModel1.swift
//  ShoppingApp
//
//  Created by ComputerVision AI on 8/4/24.
//

import Foundation

class ItemModel {
    let id: Int
    let name: String
    let icon: String
    let price: Double
    
    init(id: Int, name: String, icon: String, price: Double) {
        self.id = id
        self.name = name
        self.icon = icon
        self.price = price
    }
}
