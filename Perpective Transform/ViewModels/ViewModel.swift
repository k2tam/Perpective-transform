//
//  ViewModel.swift
//  Perpective Transform
//
//  Created by k2 tam on 25/08/2023.
//

import Foundation
import UIKit

protocol ViewModelDelegate: AnyObject {
    func completeSetupPointAndDeviceView(deviceView: UIView)
}

class ViewModel {
    public weak var delegate: ViewModelDelegate?
    
    var containerView: UIView
    var devices: [Device] = []
    var points: [Point] = []
    
    var deviceViews: [DeviceViewModel] = []
    
    init(containerView: UIView){
        self.containerView = containerView
    }
    
    /// Add device view to devices array to place in container view
    /// - Parameters:
    ///   - containerView: container view to place device view
    ///   - deviceID: device ID
    ///   - deviceName: device name
    ///   - deviceImg: image string of device in assets
    ///   - coordinate: coordinate center of device view to screen coordinate
    ///   - width: width of device view
    ///   - height: height of device view

    func addADeviceView( device: Device ,coordinate: CGPoint, size: CGSize) {
        
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
    
    /// Setup device view frame center to its point
    /// - Parameters:
    ///   - device: <#device description#>
    ///   - coordinate: <#coordinate description#>
    ///   - size: <#size description#>
    private func setupDeviceView(from device: Device, coordinate: CGPoint, size: CGSize) {
        let deviceView = DeviceView()
        
        
//        deviceView.frame = CGRect(x: coordinate.x, y: coordinate.y, width: size.width, height: size.height)
        deviceView.frame = CGRect(x: coordinate.x, y: coordinate.y, width: size.width, height: size.height)
        deviceView.configure(from: device)
        
        
        let deviceViewModel = DeviceViewModel(id: device.id, view: deviceView, coordinate: coordinate)
        
        //Point in containerView coordinate system
        let point = UIView(frame: CGRect(origin: containerView.convert(deviceViewModel.view
            .frame.origin, from: containerView.superview), size: CGSize(width: 1, height: 1) ) )
        
        let pointOfDevice = Point(id: deviceViewModel.id, view: point,oriCoordinate: deviceViewModel.view.frame.origin)
        
        points.append(pointOfDevice)
        containerView.addSubview(point)

        
        deviceViewModel.view.center = pointOfDevice.oriCoordinate

        delegate?.completeSetupPointAndDeviceView(deviceView: deviceViewModel.view)
        
        deviceViews.append(DeviceViewModel(id: device.id, view: deviceView, coordinate: coordinate))
    }

    
    
    func drawLanLines(modemCenterPoint: CGPoint,lanDevices: [Device]){
        
        let centerOfLanDevices =  calculateLansCenters(parentView: containerView, modemCenterPoint: modemCenterPoint, deviceConnectLans: lanDevices)
        
        
        for i in 0...lanDevices.count - 1{
            
            let lanDevice = lanDevices[i]
            
            addADeviceView( device: lanDevices[i], coordinate: centerOfLanDevices[i], size: DeviceSize.macbook.size)
            
            let pointOfLanDevice = points.first { point in
            
                return point.id == lanDevice.id
                
            }

            guard let pointOfLanDevice = pointOfLanDevice else {
                return
            }
            
            
           
            
           
        }
    

    }
    
    
    /// Function to draw curved lan line from start poin to end point
    /// - Parameters:
    ///   - startPoint: start point
    ///   - endPoint: endpoint
    private func addALanLineFromStartPointtoEndPoint(startPoint: CGPoint, endPoint: CGPoint) {
        let line = CAShapeLayer()
        
        line.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let path = UIBezierPath()
        
        let localStartPoint = CGPoint(x: startPoint.x, y: startPoint.y)
        
        path.move(to: localStartPoint)
        let radius = 20.0
        
        let center = CGPoint(x: endPoint.x +  radius, y: localStartPoint.y + radius)
        
        path.addArc(withCenter: CGPoint(x: center.x, y: center.y), radius: radius, startAngle: 3 * CGFloat.pi / 2, endAngle: CGFloat.pi, clockwise: false)
        
        path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        
        line.fillColor = nil
        path.lineWidth = 2.0
        line.strokeColor = UIColor.blue.cgColor
        path.stroke()
        
        line.path = path.cgPath
        
        path.close()
        
        containerView.layer.insertSublayer(line, at: 0)
    }
    
    
    /// Func to  calculate centers of  lan devices
    /// - Parameters:
    ///   - parentView: the parent view containt modem and lan devices
    ///   - modemCenterPoint: center point of modem
    ///   - deviceConnectLans: List of devices connect to modem 
    /// - Returns: Center point of lan devices
    func calculateLansCenters(parentView: UIView ,modemCenterPoint: CGPoint ,deviceConnectLans: [Device]) -> [CGPoint] {
        
        var centerPointOfLanDevices: [CGPoint] = []
        
        let padding = 10.0
        let containerWidth = UIScreen.main.bounds.width - padding * 2
        
        //Vertical space between modem to devices
        let verticalSpaceBetweenModemToDevices = 100.0
        
        let yCenterOfDevices = modemCenterPoint.y + verticalSpaceBetweenModemToDevices
        
        //Spacing between devices center
        let spacingOfDevicesCenter = containerWidth / ( CGFloat(deviceConnectLans.count) + 1.0 )
        
        for i in 1...deviceConnectLans.count {
            centerPointOfLanDevices.append(
                CGPoint(
                    x: (spacingOfDevicesCenter * CGFloat(i)) + padding,
                    y: yCenterOfDevices
                ))
            
        }
   
        return centerPointOfLanDevices
        
    }
    
    
}
