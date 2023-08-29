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
    
    
    /// Add device view to devices array to place in container view
    /// - Parameters:
    ///   - containerView: container view to place device view
    ///   - deviceID: device ID
    ///   - deviceName: device name
    ///   - deviceImg: image string of device in asse
    ///   - coordinate: coordinate of device view to screen coordinate
    ///   - width: width of device view
    ///   - height: height of device view

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
            
            // Store the original width and height in the device object
            let device = Device(id: deviceID, name: deviceName, view: deviceView, oriSize: CGSize(width: width, height: height))
                        
            
            // Add the device view to the container view
            devices.append(device)
        } else {
            print("Coordinate of deviceID: \(deviceID) is outside the bounds of the container view")
        }
    }

    
    
}
