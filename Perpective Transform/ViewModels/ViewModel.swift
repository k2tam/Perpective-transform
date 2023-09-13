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
    func drawSingalElipseWithRadius(radius: Double)
    func addClientViewAfterDeterminedCoordinate(device: Device,coordinate: CGPoint)
    
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
    func addADeviceView( device: Device ,coordinate: CGPoint) {

        setupDeviceView(from: device, coordinate: coordinate, size: device.deviceSize)
    }
    
    /// Setup device view frame center to its point
    /// - Parameters:
    ///   - device: Device object
    ///   - coordinate: coordinate center of device view to screen cordinate
    private func setupDeviceView(from device: Device, coordinate: CGPoint, size: CGSize) {
        let deviceView = DeviceView()
        
        deviceView.configure(from: device)
        
        //Set fit width for label deivce
        let widthDeviceFrameFitLabel =  deviceView.getWidthThatFitTextInLabel() + 20
        deviceView.frame = CGRect(x: coordinate.x, y: coordinate.y, width: widthDeviceFrameFitLabel, height: size.height)
        
        let deviceViewModel = DeviceViewModel(id: device.id, view: deviceView, coordinate: coordinate)
        
        //Point in containerView coordinate system
        let point = UIView(frame: CGRect(origin: containerView.convert(deviceViewModel.view
            .frame.origin, from: containerView.superview), size: CGSize(width: 2, height: 2) ) )
        
        if device.id == 10 {
            point.backgroundColor = .red
        }
        
        let pointOfDevice = Point(
            id: deviceViewModel.id,
            view: point,
            oriCoordinate: deviceViewModel.view.frame.origin
        )
        
        points.append(pointOfDevice)
        containerView.addSubview(point)
        
        deviceViewModel.view.center = pointOfDevice.oriCoordinate
        
        delegate?.completeSetupPointAndDeviceView(deviceView: deviceViewModel.view)
        deviceViews.append(DeviceViewModel(id: device.id, view: deviceView, coordinate: coordinate))
    }
    
    /// Function setup lan devices and the lan lines connect to its
    /// - Parameters:
    ///   - modemCenterPoint: CGPoint center of modem view
    ///   - lanDevices: List of lan devices
    func setupLanDevicesAndLanLines(modemCenterPoint: CGPoint,lanDevices: [Device]){
        
        //Vertical space between modem to devices
        let verticalSpaceBetweenModemToDevices = 250.0
        
        //Calculate the arranged centers point of lan devices
        let centerOfLanDevices =  calculateLansCenters(parentView: containerView, modemCenterPoint: modemCenterPoint, verticalSpaceBetweenModemToDevices: verticalSpaceBetweenModemToDevices, deviceConnectLans: lanDevices)
        
        let startPointOfLanLines = CGPoint(x: modemCenterPoint.x, y: modemCenterPoint.y + 12)

        //Case just have one device then draw a straight lan line
        if lanDevices.count == 1 {
            let lanDevice = lanDevices[0]
            
            addADeviceView( device: lanDevice, coordinate: centerOfLanDevices[0])

            let pointOfLanDevice = points.first { point in
                return point.id == lanDevice.id
            }

            guard let pointOfLanDevice = pointOfLanDevice else {
                return
            }
            
            let spaceEndpointLanLineToDevice = lanDevice.deviceSize.height / 2  -  10
            
            addAStraightLanLine(
                spaceToLanDevice: spaceEndpointLanLineToDevice,
                startPoint: startPointOfLanLines,
                endPoint: pointOfLanDevice.view.frame.origin)
        }
        
        else{
            for i in 0...lanDevices.count - 1{

                let lanDevice = lanDevices[i]
                let spaceEndpointLanLineToDevice = lanDevice.deviceSize.height / 2 - 10
                
                addADeviceView(device: lanDevices[i], coordinate: centerOfLanDevices[i])

                let pointOfLanDevice = points.first { point in
                    return point.id == lanDevice.id
                }

                guard let pointOfLanDevice = pointOfLanDevice else {
                    return
                }

                if pointOfLanDevice.view.frame.origin.x == modemCenterPoint.x {
                    addAStraightLanLine(
                        spaceToLanDevice: spaceEndpointLanLineToDevice,
                        startPoint: startPointOfLanLines,
                        endPoint: pointOfLanDevice.view.frame.origin)
                }else {

                    addACurvedLanLine(
                        spaceToLanDevice: spaceEndpointLanLineToDevice,
                        startPoint: startPointOfLanLines,
                        endPoint: pointOfLanDevice.view.frame.origin)
                }
            }
        }
        
    }
    
    func addAStraightLanLine(spaceToLanDevice: CGFloat,startPoint: CGPoint, endPoint: CGPoint){
        let line = CAShapeLayer()
        let path = UIBezierPath()

        line.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        path.move(to: startPoint)
        path.lineWidth = 2.0
        line.fillColor = nil
        line.strokeColor = UIColor.blue.cgColor
        path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y - spaceToLanDevice))
        
        path.close()
        line.path = path.cgPath
        containerView.layer.insertSublayer(line, at: 0)

    }
    
     func addACurvedLanLine(spaceToLanDevice: CGFloat, startPoint: CGPoint, endPoint: CGPoint) {
        let line = CAShapeLayer()
        
        line.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        let path = UIBezierPath()

        path.move(to: startPoint)
        
        let radius = 20.0
        var centerOfArc = CGPoint()
         
         //Case lan device is at half right screen draw right curved line
         if(endPoint.x > startPoint.x){
             centerOfArc = CGPoint(x: endPoint.x - radius, y: startPoint.y + radius)
             path.addArc(
                withCenter: CGPoint(x: centerOfArc.x, y: centerOfArc.y),
                radius: radius, startAngle: 3 * CGFloat.pi / 2,
                endAngle: 2 * CGFloat.pi, clockwise: true
             )
         }else{
             //Case lan device is at half left screen draw right curved line
              centerOfArc = CGPoint(x: endPoint.x +  radius, y: startPoint.y + radius)
             
             path.addArc(
                withCenter: CGPoint(x: centerOfArc.x, y: centerOfArc.y),
                radius: radius, startAngle: 3 * CGFloat.pi / 2,
                endAngle: CGFloat.pi, clockwise: false
             )
         }
         
        path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y - spaceToLanDevice))
        
        line.fillColor = nil
        path.lineWidth = 2.0
        line.strokeColor = UIColor.blue.cgColor
        
        line.path = path.cgPath
        path.close()

        containerView.layer.insertSublayer(line, at: 0)
    }
    
    /// Func to  calculate centers of  lan devices
    /// - Parameters:
    ///   - parentView: the parent view containt modem and lan devices
    ///   - verticalSpaceBetweenModemToDevices: fdfhdj
    ///   - modemCenterPoint: center point of modem
    ///   - deviceConnectLans: List of devices connect to modem 
    /// - Returns: Center point of lan devices
    func calculateLansCenters(parentView: UIView ,modemCenterPoint: CGPoint ,verticalSpaceBetweenModemToDevices: CGFloat ,deviceConnectLans: [Device]) -> [CGPoint] {
        
        var centerPointOfLanDevices: [CGPoint] = []
        
        let padding = 44.0
        let containerWidth = UIScreen.main.bounds.width - padding * 2
        
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
    
    //MARK: - Setup signal circle views
    /// Setup circle views on container view
     func setupCircleViews() {
         devices.append(contentsOf: [
            Device(id: 1, name: "Macbook", status: .green, deviceType: .macbook, deviceImg: DeviceImg.macbook),
            Device(id: 2, name: "Iphone X", status: .green, deviceType: .iphone, deviceImg: DeviceImg.iphone),
            Device(id: 3, name: "Iphone X", status: .green, deviceType: .iphone, deviceImg: DeviceImg.iphone),
            Device(id: 0, name: "Iphone X", status: .green, deviceType: .iphone, deviceImg: DeviceImg.iphone),

         ])
        
         
        let pointOfModem = points.first(where: { point in
             return point.id == 10
        })
         
         guard let pointOfModem = pointOfModem else {
             return
         }
        
         
         var circleStrongRadius = 120.0
         
         
         
         
         
        let circleStrong = CircleView(
            frame: CGRect(x: 0, y: 0, width: circleStrongRadius * 2, height: circleStrongRadius * 2),
            gradientStartPoint: CGPoint(x: 0.5, y: 0),
            gradientEndPoint: CGPoint(x: 0.5, y: 1.5))
        
        circleStrong.center = pointOfModem.view.center
  
         
         
         
//
//        let circleMedium = CGPoint(x: centerContainerViewX, y: startLineOfSignal - 150)
//        let circle2 = CircleView(
//            frame: CGRect(x: 0, y: 0, width: 500, height: 450),
//            gradientStartPoint: CGPoint(x: 0.5, y: 0),
//            gradientEndPoint: CGPoint(x: 0.5, y: 1))

        //        circle2.center = CGPoint(x: signalViewCenter2.x, y: signalViewCenter2.y)
        //
        //        let signalViewCenter3 = CGPoint(x: centerContainerViewX, y: startLineOfSignal - 300)
        //        let circle3 = CircleView(
        //            frame: CGRect(x: 0, y: 0, width: 600, height: 450),
        //            gradientStartPoint: CGPoint(x: 0.5, y: 0),
        //            gradientEndPoint: CGPoint(x: 0.5, y: 1))
        //
        //        circle3.center = CGPoint(x: signalViewCenter3.x, y: signalViewCenter3.y)
        
        
        containerView.addSubViews(circleStrong)
         
         var strongDevices = devices.filter { device in
             return device.status == .green
         }
         
         drawClientsOnCircle(center: circleStrong, devices: strongDevices, maximumDevices: 4 ,radius: circleStrongRadius - 15.0)
    }
    
    ///https://github.com/onmyway133/blog/issues/673
    func drawClientsOnCircle(center: UIView, devices: [Device], maximumDevices: Int, radius: CGFloat) {
        guard let delegate = delegate else {
            return
        }
        
        let numberOfDevices = devices.count
        
        if numberOfDevices < 1 {
            return
        }
        
        let startDegree =  Double.pi
        let endDegree =  2 * Double.pi 
//
        
        let degreeAllocation = (endDegree - startDegree) / Float64(numberOfDevices + 1)
                                         
        
        for i in 0...numberOfDevices - 1{
            let degree = degreeAllocation * Double(i + 1) + Double.pi + (startDegree - Double.pi)
            let hOffSet = radius * cos(degree)
            let vOffSet = radius * sin(degree)


            delegate.addClientViewAfterDeterminedCoordinate(
                device: devices[i],
                coordinate: CGPoint(x: center.center.x + hOffSet,y: center.center.y + vOffSet)
            )
        }
    }
    
    
}
