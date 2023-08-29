//
//  CircleView.swift
//  Perpective Transform
//
//  Created by k2 tam on 29/08/2023.
//

import UIKit

class CircleView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Remove any existing sublayers
        layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // Create a circular shape layer
        let circleLayer = CAShapeLayer()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = min(bounds.width, bounds.height) / 2.0
        
        // Create a circular path
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        circleLayer.path = path.cgPath
        
        // Customize the appearance of the circle
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = UIColor.red.cgColor
        circleLayer.lineWidth = 2.0
        
        // Add the circle layer to the view's layer
        layer.addSublayer(circleLayer)
    }
}
