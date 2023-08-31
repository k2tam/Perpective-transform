//
//  CircleView.swift
//  Perpective Transform
//
//  Created by k2 tam on 30/08/2023.
//


import UIKit

class CircleView: UIView {
    let gradientStartPoint: CGPoint
    let gradientEndPoint: CGPoint
    
    // Override the designated initializer of UIView
    override init(frame: CGRect) {
        self.gradientStartPoint = CGPoint(x: 0.5, y: 0)
        self.gradientEndPoint = CGPoint(x: 0.5, y: 0.15)
        
        super.init(frame: frame)
    }
    
    init(frame: CGRect, gradientStartPoint: CGPoint, gradientEndPoint: CGPoint) {
        self.gradientStartPoint = gradientStartPoint
        self.gradientEndPoint = gradientEndPoint


        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func draw(_ rect: CGRect) {
        
        let circlePath = UIBezierPath(ovalIn: rect)
        let gradientLayer = CAGradientLayer()
        
        
        let gradientColors: [CGColor] = [
            UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.20).cgColor,
            UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0.15).cgColor,
            UIColor(red: 217/255, green: 217/255, blue: 217/255, alpha: 0).cgColor,
        ]
        
        gradientLayer.locations = [0,0.1,0.2,1]
        gradientLayer.frame = bounds
        gradientLayer.colors = gradientColors
        gradientLayer.startPoint = self.gradientStartPoint
        gradientLayer.endPoint = self.gradientEndPoint
        

        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        gradientLayer.mask = shapeLayer
        
        layer.addSublayer(gradientLayer)
        
        
        
    }
}
