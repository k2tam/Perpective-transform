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
                transformContainer = CATransform3DRotate(transformContainer, CGFloat(-20 * Double.pi / 180), 1, 0, 0)
                
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
        setupViews()
        setupAnimation()
    }
    
    func setupViews() {
        guard let vm = vm else {return}
        
        vm.addADeviceView(containerView: containerView,deviceID: 1 ,deviceName: "Iphone", coordinate: CGPoint(x: 60, y: 140), width: 30, height: 60)
        vm.addADeviceView(containerView: containerView,deviceID: 2, deviceName: "Mac 1", coordinate: CGPoint(x: 300, y: 110), width: 60, height: 40)
        vm.addADeviceView(containerView: containerView,deviceID: 3, deviceName: "Mac 2", coordinate: CGPoint(x: 150, y: 200), width: 60, height: 40)
        
        vm.addADeviceView(containerView: containerView,deviceID: 4, deviceName: "Mac 3", coordinate: CGPoint(x: 300, y: 400), width: 60, height: 40)
        vm.addADeviceView(containerView: containerView,deviceID: 5, deviceName: "Mac 4", coordinate: CGPoint(x: 300, y: 400), width: 60, height: 40)
        vm.addADeviceView(containerView: containerView,deviceID: 6, deviceName: "Mac 5", coordinate: CGPoint(x: 200, y: 500), width: 60, height: 40)
        
        
        for device in vm.devices {
            let deviceViewFrame = device.view.frame
            
            //Point in containerView coordinate system
            let point = UIView(frame: CGRect(origin: containerView.convert(deviceViewFrame.origin, from: containerView.superview), size: CGSize(width: 5, height: 5) ) )
            
            let pointOfDevice = Point(id: device.id, view: point,oriCoordinate: device.view.frame.origin)
            vm.points.append(pointOfDevice)
            
            
            device.view.center = pointOfDevice.oriCoordinate
            
            containerView.addSubview(point)
            self.view.addSubview(device.view)
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
            
            let deviceOfThisPoint = vm.devices.first { device in
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
                    scaleFactor = 1.0 + min(max((point.transCoordinate!.y - containerViewCenterY) / containerViewCenterY, 0), 0.5)
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
    }
    
}

extension ViewController {
    func setupAnimation() {
        containerAnimation.toValue = NSValue(caTransform3D:transformContainer)
        containerAnimation.duration = 3
        
        positionAnimation.duration = 0.65
        containerAnimation.duration = 0.6
        
    }
    
}

