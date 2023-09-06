//
//  Device.swift
//  Perpective Transform
//
//  Created by k2 tam on 25/08/2023.
//

import Foundation
import UIKit

enum DeviceStatus {
    case green
    case yellow
    case red
}

enum DeviceImg: String {
    case iphone = "iphone_X"
    case macbook = "macbook"
    case samsung = "samsung"
    case modem = "modem"
    case pc = "pc"
}

enum DeviceSize {
    case iphoneX
    case macbook
    case modem
    
    var size: CGSize {
        switch self {
        case .iphoneX:
            return CGSize(width: 80, height: 70)
        case .modem:
            return CGSize(width: 100, height: 100)
        case .macbook:
            return CGSize(width: 90, height: 80)
            
        }
    }
}

struct Device {
    var id: Int
    var name: String
    var status: DeviceStatus
    var deviceImg: DeviceImg
}

struct DeviceViewModel {
    var id: Int
    var view: UIView
    var coordinate: CGPoint
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
