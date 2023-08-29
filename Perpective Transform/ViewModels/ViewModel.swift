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
    
    var deviceViews: [DeviceViewModel] = []
    

    /// Add device view to devices array to place in container view
    /// - Parameters:
    ///   - containerView: container view to place device view
    ///   - deviceID: device ID
    ///   - deviceName: device name
    ///   - deviceImg: image string of device in assets
    ///   - coordinate: coordinate of device view to screen coordinate
    ///   - width: width of device view
    ///   - height: height of device view

    func addADeviceView(containerView: UIView, device: Device ,coordinate: CGPoint, size: CGSize) {
        let containerFrame = containerView.frame
        
        // Convert the given coordinate to a point within the containerView's coordinate system
        let coordinateToContainerView = containerView.convert(coordinate, from: containerView.superview)
        
        // Check if the given coordinate is within the bounds of the container view
        if containerFrame.contains(coordinate) {
            
            // Create and configure the device view
            setupDeviceView(from: device, coordinate: coordinate, size: size)
        } else {
            print("Coordinate of deviceID: \(device.id) is outside the bounds of the container view")
        }
    }
    
    private func setupDeviceView(from device: Device, coordinate: CGPoint, size: CGSize) {
        let deviceView = DeviceView()
        
        deviceView.frame = CGRect(x: coordinate.x, y: coordinate.y, width: size.width, height: size.height)
        deviceView.configure(from: device)
        
        deviceViews.append(DeviceViewModel(id: device.id, view: deviceView, coordinate: coordinate))
    }

    
    
}
