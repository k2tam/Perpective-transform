//
//  Device.swift
//  Perpective Transform
//
//  Created by k2 tam on 25/08/2023.
//

import Foundation
import UIKit

struct Device {
    var id: Int
    var name: String
    var view: UIView
}

class Point {
    var id: Int
    var view: UIView
    var oriCoordinate: CGPoint //Oricordinate to superView coor system
    var transCoordinate: CGPoint? //Trans coordinate to superview coor system
    
    init(id: Int, view: UIView, oriCoordinate: CGPoint, transCoordinate: CGPoint? = nil) {
        self.id = id
        self.view = view
        self.oriCoordinate = oriCoordinate
        self.transCoordinate = transCoordinate
    }
}
