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
    
    var transformMatrix = CATransform3DIdentity
    var originalDeviceViewCenter: CGPoint = .zero
    var dotViewOriginalCenter: CGPoint = .zero
    
   
    
    //MARK: - 2 finger pan gesture to switch 2D/3D mode
    lazy var swipeGestureTogglePerpectiveMode: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(twoFingerDidSwipe(_:)))
        gesture.minimumNumberOfTouches = 2
        gesture.maximumNumberOfTouches = 2
        return gesture
    }()
    
    @objc func twoFingerDidSwipe(_ recognizer: UIPanGestureRecognizer) {
        let swipeThreshold: CGFloat = 50

        if recognizer.state == .changed {
            let translation = recognizer.translation(in: view)

            if translation.y < -swipeThreshold {
                // Swipe Up
                if !is3D {
                    is3D = true
                }
            } else if translation.y > swipeThreshold {
                // Swipe Down
                if is3D {
                    is3D = false
                }
            }
        }
    }
    
    var is3D = false {
        didSet {
            if is3D {
                // Set the  m34 value for 3D effect
                let perspective: CGFloat = 1.0 / 200.0  // Negative value for inward perspective
                transformMatrix.m34 = perspective
                transformMatrix = CATransform3DRotate(transformMatrix, CGFloat(-20 * Double.pi / 180), 1, 0, 0)
            }else {
                //Remove 3D transformation
                transformMatrix = CATransform3DIdentity
            }
            
            animateTransform()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = ViewModel(containerView: containerView)
        vm?.delegate = self
        
//        containerView.backgroundColor = .green
        
        setupGridView()
        

        
        setupViews()
        

        setupAnimation()
        
        // Add the two-finger pan gesture to the containerView
        view.addGestureRecognizer(swipeGestureTogglePerpectiveMode)
    }
    
    func setupViews() {
        guard let vm = vm else {return}
        

        
//        containerView.backgroundColor = .green
        
        setAnchorPoint(anchorPoint: CGPoint(x: 0.5, y: 0.5), forView: containerView)


        
        vm.addADeviceView(
            device: Device(id: 10, name: "EP9108W-4FE", status: .green, deviceType: .modem, deviceImg: DeviceImg.modem),

            coordinate: self.view.convert(CGPoint(x: containerView.bounds.width/2, y: containerView.bounds.height/2), from: containerView))

       
        

//        vm.addADeviceView(
//            device: Device(id: 2, name: "Iphone X", status: .green, deviceType: .iphone, deviceImg: DeviceImg.iphone),
//            coordinate: CGPoint(x: 90, y: 390))

        

    
//        vm.addADeviceView(
//            device: Device(id: 4, name: "Iphone X", status: .red, deviceType: .iphone, deviceImg: DeviceImg.iphone),
//            coordinate: CGPoint(x: 250, y: 100))
        

        var pointOfModem = vm.points.first(where: { point in
            return point.id == 10
        })
        
        var lanDevices = [
            Device(id: 5, name: "PC 1", status: .green, deviceType: .macbook, deviceImg: .macbook),
            Device(id: 6, name: "PC 2", status: .green, deviceType: .macbook, deviceImg: .macbook),
            Device(id: 7, name: "PC 3", status: .green, deviceType: .macbook, deviceImg: .macbook),
            Device(id: 8, name: "PC 4", status: .green, deviceType: .macbook, deviceImg: .macbook),

        ]

        vm.setupLanDevicesAndLanLines(modemCenterPoint: pointOfModem!.view.frame.origin, lanDevices: lanDevices)
        
        //Set up signal circle views
        vm.setupCircleViews()
    }
    
    func setAnchorPoint(anchorPoint: CGPoint, forView view: UIView) {
        var newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y)
        
        newPoint = CGPointApplyAffineTransform(newPoint, view.transform)
        oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform)
        
        var position = view.layer.position
        position.x -= oldPoint.x
        position.x += newPoint.x
        
        position.y -= oldPoint.y
        position.y += newPoint.y
        
        view.layer.position = position
        view.layer.anchorPoint = anchorPoint
    }
    
    func animateTransform() {
        guard let vm = vm else {return}
        
        containerAnimation.fromValue = NSValue(caTransform3D: containerView.layer.transform)
        containerAnimation.toValue = NSValue(caTransform3D: transformMatrix)
        // Animation duration in seconds
        containerView.layer.add(containerAnimation, forKey: nil)
        
        // Apply the final transform after the animatßion completes
        containerView.layer.transform = transformMatrix
        
        
        let pointOfModem = vm.points.first(where: { point in
             return point.id == 10
        })
        
        guard let pointOfModem = pointOfModem else { return}
//        let containerViewCenterY = containerView.frame.height / 2
        
        //Set center for scaling up down
        let containerViewCenterY = pointOfModem.oriCoordinate.y

        
        
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
                    let scaleFactorRange: CGFloat = 0.4  // Adjust this range as needed
                    scaleFactor = 1.0 +
                    min(
                        max((point.transCoordinate!.y - containerViewCenterY) / containerViewCenterY, 0),
                        scaleFactorRange
                    )
                } else {
                    // Scale the subviews from centerY to top
                    let scaleFactorRange: CGFloat = 0.4  // Adjust this range as needed
                    scaleFactor = 1.0 -
                    min(
                        max((containerViewCenterY - point.transCoordinate!.y) / containerViewCenterY, 0),
                        scaleFactorRange
                    )
                    
                }
                
                // Apply the scaling factor to the subview
                deviceOfThisPoint.view.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        
                deviceOfThisPoint.view.alpha = scaleFactor
   
            }
            else {
                positionAnimation.fromValue = NSValue(cgPoint: pointTransCoordinate)
                positionAnimation.toValue = NSValue(cgPoint: point.oriCoordinate)
                
                deviceOfThisPoint.view.alpha = 1

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
        containerAnimation.toValue = NSValue(caTransform3D:transformMatrix)
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
}


extension ViewController: ViewModelDelegate {
    func drawSingalElipseWithRadius(radius: Double) {
        
    }
    
    func addClientViewAfterDeterminedCoordinate(device: Device, coordinate: CGPoint) {
        guard let vm = vm else {return}
        
        let coordinateInScreenSys = self.view.convert(coordinate, from: containerView)

        vm.addADeviceView(
            device: device,
            coordinate: CGPoint(x: coordinateInScreenSys.x, y: coordinateInScreenSys.y))
}
    
    func completeSetupPointAndDeviceView(deviceView: UIView) {
        self.view.addSubview(deviceView)
    }
    
    func drawSingalElipseWithRadius(radius: Double, center: CGPoint) {
        let elipseSignalView: UIImageView = {
            let image = UIImageView()
            return image
        }()
        
        
        
        elipseSignalView.center = center
        containerView.addSubViews(elipseSignalView)

    }

}

