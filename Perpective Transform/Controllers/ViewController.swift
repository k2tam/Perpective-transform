//
//  ViewController.swift
//  Perpective Transform
//
//  Created by k2 tam on 24/08/2023.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!
    
    var vm: ViewModel?
    
    let containerAnimation = CABasicAnimation(keyPath: "transform")
    let positionAnimation = CABasicAnimation(keyPath: "position")
    
    var transformContainer = CATransform3DIdentity
    var originalDeviceViewCenter: CGPoint = .zero
    
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
        setupGridView()
        setupViews()
        setupAnimation()
    }
    
    func setupViews() {
        guard let vm = vm else {return}
        
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 1, name: "Iphone X", status: .green, deviceImg: DeviceImg.iphone),
            coordinate: CGPoint(x: 60, y: 410),
            size: CGSize(width: 80, height: 70))
        
        vm.addADeviceView(
            containerView: containerView,
            device: Device(id: 2, name: "Macbook", status: .green, deviceImg: DeviceImg.macbook),
            coordinate: CGPoint(x: 250, y: 500),
            size: CGSize(width: 90, height: 80))
        
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
                    scaleFactor = 1.0 + min(max((point.transCoordinate!.y - containerViewCenterY) / containerViewCenterY, 0), 0.3)
                } else {
                    // Scale the subviews from centerY to top
                    scaleFactor = 1.0 - min(max((containerViewCenterY - point.transCoordinate!.y) / containerViewCenterY, 0), 0.5)
                }
                
                // Apply the scaling factor to the subview
                deviceOfThisPoint.view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
                
                
            }
            else {
                containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
                
                
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
        let gridView = GridView(frame: containerView.bounds)
        gridView.backgroundColor = .clear
        containerView.addSubview(gridView)
        
    }
    
}

