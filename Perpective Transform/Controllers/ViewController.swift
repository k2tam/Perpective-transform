//
//  ViewController.swift
//  Perpective Transform
//
//  Created by k2 tam on 24/08/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    let gridView = GridView()

    
    var vm: ViewModel?
    
    
    
    let containerAnimation = CABasicAnimation(keyPath: "transform")
    let positionAnimation = CABasicAnimation(keyPath: "position")
    
    var transformContainer = CATransform3DIdentity
    var originalDeviceViewCenter: CGPoint = .zero
    
    var dotViewOriginalCenter: CGPoint = .zero
    
    
    var is3D = false {
        didSet {
            if is3D {
                // Set the  m34 value for 3D effect
                let perspective: CGFloat = 1.0 / 200.0  // Negative value for inward perspective
                transformContainer.m34 = perspective
                transformContainer = CATransform3DRotate(transformContainer, CGFloat(-25 * Double.pi / 180), 1, 0, 0)
                
            }else {
                //Remove 3D transformation
                transformContainer = CATransform3DIdentity
            }
            
            animateTransform()
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ViewModel()
        
        setupCircleViews()
        setupGridView()
        
        setupViews()
        setupAnimation()
    }
    
    func setupViews() {
        guard let vm = vm else {return}
        
        
        
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 1, name: "Iphone X", status: .green, deviceImg: DeviceImg.iphone),
            coordinate: CGPoint(x: 90, y: 390),
            size: CGSize(width: 80, height: 70))
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 3, name: "Iphone X", status: .yellow, deviceImg: DeviceImg.iphone),
            coordinate: CGPoint(x: 110, y: 300),
            size: CGSize(width: 80, height: 70))
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 4, name: "Iphone X", status: .red, deviceImg: DeviceImg.iphone),
            coordinate: CGPoint(x: 250, y: 100),
            size: CGSize(width: 80, height: 70))
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 2, name: "Macbook", status: .green, deviceImg: DeviceImg.macbook),
            coordinate: CGPoint(x: 100, y: 530),
            size: CGSize(width: 90, height: 80))
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 5, name: "EP9108W-4FE", status: .green, deviceImg: DeviceImg.modem),
            coordinate: view.center,
            size: CGSize(width: 100, height: 100))
        
        
        
        
        
        for deviceView in vm.deviceViews {
            //            let deviceViewFrame = deviceView.view.frame
            
            //Point in containerView coordinate system
            let point = UIView(frame: CGRect(origin: containerView.convert(deviceView.view
                .frame.origin, from: containerView.superview), size: CGSize(width: 5, height: 5) ) )
            
            let pointOfDevice = Point(id: deviceView.id, view: point,oriCoordinate: deviceView.view.frame.origin)
            vm.points.append(pointOfDevice)
            
            
            deviceView.view.center = pointOfDevice.oriCoordinate
            
            containerView.addSubview(point)
            self.view.addSubview(deviceView.view)

        }
        
        var pointOfModem = vm.points.first(where: { point in
            return point.id == 5
        })
        
        var pointOfMac = vm.points.first { point in
            return point.id == 2
        }
        
        addLanLine(startPoint: pointOfModem!.view.frame.origin, endPoint: pointOfMac!.view
            .frame.origin)

        
    }
    
    func animateTransform() {
        guard let vm = vm else {return}
        
        containerAnimation.fromValue = NSValue(caTransform3D: containerView.layer.transform)
        containerAnimation.toValue = NSValue(caTransform3D: transformContainer)
        // Animation duration in seconds
        containerView.layer.add(containerAnimation, forKey: nil)
        
        // Apply the final transform after the animation completes
        containerView.layer.transform = transformContainer
        
        let containerViewCenterY = containerView.frame.height / 2
        
        
        // Get the point's coordinates within the parent view after transform
        for point in vm.points {
            let transformedPointCoordinates = point.view.convert(CGPoint.zero, to: self.view)
            
            if point.transCoordinate == nil {
                point.transCoordinate = transformedPointCoordinates
            }
            
            let deviceOfThisPoint = vm.deviceViews.first { device in
                device.id == point.id
            }
            
            guard let deviceOfThisPoint = deviceOfThisPoint else {return}
            
            guard let pointTransCoordinate = point.transCoordinate else {return}
            
            // Calculate zPosition based on the vertical position of the device view
            let zPosition = containerView.frame.height - point.transCoordinate!.y
            // Apply the calculated zPosition
            deviceOfThisPoint.view.layer.zPosition = zPosition
            
            
            if is3D {
                positionAnimation.fromValue = NSValue(cgPoint: point.oriCoordinate)
                positionAnimation.toValue = NSValue(cgPoint: pointTransCoordinate)
                deviceOfThisPoint.view.center = pointTransCoordinate
                
                var scaleFactor: CGFloat = 1.0
                
                if point.transCoordinate!.y >= containerViewCenterY {
                    // Scale the subviews from centerY to bottom
                    let scaleFactorRange: CGFloat = 0.3  // Adjust this range as needed
                    scaleFactor = 1.0 + min(max((point.transCoordinate!.y - containerViewCenterY) / containerViewCenterY, 0), scaleFactorRange)
                } else {
                    // Scale the subviews from centerY to top
                    let scaleFactorRange: CGFloat = 0.5  // Adjust this range as needed
                    scaleFactor = 1.0 - min(max((containerViewCenterY - point.transCoordinate!.y) / containerViewCenterY, 0), scaleFactorRange)
                }
                
                // Apply the scaling factor to the subview
                deviceOfThisPoint.view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                
                
            }
            else {
                
                
                positionAnimation.fromValue = NSValue(cgPoint: pointTransCoordinate)
                positionAnimation.toValue = NSValue(cgPoint: point.oriCoordinate)
                deviceOfThisPoint.view.center = point.oriCoordinate
                deviceOfThisPoint.view.transform = .identity
                
                
                
            }
            
            deviceOfThisPoint.view.layer.add(positionAnimation, forKey: nil)
            
        }
    }
    
    @IBAction func transformPressed(_ sender: UIButton) {
        
        is3D = !is3D
        
        if(is3D){
            gridView.isHidden = false

        }else{
            gridView.isHidden = true
        }
        
        view.bringSubviewToFront(sender)
    }
    
}

extension ViewController {
    func setupAnimation() {
        containerAnimation.toValue = NSValue(caTransform3D:transformContainer)
        containerAnimation.duration = 3
        
        positionAnimation.duration = 0.65
        containerAnimation.duration = 0.6
    }
    
    /// Setup grid for container view background
    private func setupGridView() {
        gridView.frame = containerView.bounds
        gridView.backgroundColor = .clear
        containerView.addSubview(gridView)
        gridView.isHidden = true
        
    }
    
    
    /// Setup circle views on container view
    private func setupCircleViews() {
        
        let centerContainerViewX = containerView.bounds.width / 2
        
        
        let startLineOfSignal = containerView.bounds.height * 0.9
        
        let signalViewCenter = CGPoint(x: centerContainerViewX, y: containerView.bounds.height * 0.75)
        let circle1 = CircleView(
            frame: CGRect(x: 0, y: 0, width: 300, height: 300),
            gradientStartPoint: CGPoint(x: 0.5, y: 0),
            gradientEndPoint: CGPoint(x: 0.5, y: 1))
        
        circle1.center = CGPoint(x: signalViewCenter.x, y: signalViewCenter.y)
        
        let signalViewCenter2 = CGPoint(x: centerContainerViewX, y: startLineOfSignal - 150)
        let circle2 = CircleView(
            frame: CGRect(x: 0, y: 0, width: 450, height: 450),
            gradientStartPoint: CGPoint(x: 0.5, y: 0),
            gradientEndPoint: CGPoint(x: 0.5, y: 1))

        circle2.center = CGPoint(x: signalViewCenter2.x, y: signalViewCenter2.y)
        
        let signalViewCenter3 = CGPoint(x: centerContainerViewX, y: startLineOfSignal - 300)
        let circle3 = CircleView(
            frame: CGRect(x: 0, y: 0, width: 450, height: 450),
            gradientStartPoint: CGPoint(x: 0.5, y: 0),
            gradientEndPoint: CGPoint(x: 0.5, y: 1))

        circle3.center = CGPoint(x: signalViewCenter3.x, y: signalViewCenter3.y)
        
   
        containerView.addSubViews(circle1,circle2, circle3)
    }
    
    func addLanLine(startPoint: CGPoint, endPoint: CGPoint) {
        let line = CAShapeLayer()
        
        let controlPoint = CGPoint(x: endPoint.x, y: startPoint.y)
        
        line.frame = CGRect(x: 0, y: 0, width: 0, height: 0)

        
        let path = UIBezierPath()
        
        let localStartPoint = CGPoint(x: startPoint.x, y: startPoint.y + 10)
        
        path.move(to: localStartPoint)
        path.addQuadCurve(to: endPoint, controlPoint: controlPoint)
        
//        path.addLine(to: endPoint)
        
        
        line.fillColor = nil
        path.lineWidth = 2.0
        line.strokeColor = UIColor.blue.cgColor
        path.stroke()
        
        line.path = path.cgPath
        
        
          

        
        containerView.layer.insertSublayer(line, at: 0)
    }
    
}

