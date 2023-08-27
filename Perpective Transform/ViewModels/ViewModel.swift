//
//  ViewModel.swift
//  Perpective Transform
//
//  Created by k2 tam on 25/08/2023.
//

import Foundation
import UIKit

class ViewModel {
    var devices: [Device] = []
    var points: [Point] = []
    
    
    func addADeviceView(containerView: UIView, deviceID: Int ,deviceName: String ,coordinate: CGPoint, width: Double, height: Double) {
        let containerFrame = containerView.frame
        
        // Convert the given coordinate to a point within the containerView's coordinate system
        let coordinateToContainerView = containerView.convert(coordinate, from: containerView.superview)
        
        
        // Check if the given coordinate is within the bounds of the container view
        if containerFrame.contains(coordinate) {
            // Create and configure the device view
            let deviceView = UIView()
            deviceView.frame = CGRect(x: coordinate.x, y: coordinate.y, width: CGFloat(width), height: CGFloat(height))
            deviceView.backgroundColor = .yellow
            
            // Add the device view to the container view
            devices.append(Device(id: deviceID, name: deviceName, view: deviceView))
        } else {
            print("Coordinate is outside the bounds of the container view")
        }
    }

    
    
}
