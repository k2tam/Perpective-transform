//
//  GridView.swift
//  Perpective Transform
//
//  Created by k2 tam on 29/08/2023.
//

import UIKit

class GridView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let gridSize: CGFloat = 60.0 // Adjust this value to control grid density
        let numberOfColumns = Int(rect.width / gridSize)
        let numberOfRows = Int(rect.height / gridSize)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(UIColor.lightGray.cgColor)
        context?.setLineWidth(0.5)
        
        // Vertical lines
        for column in 1..<numberOfColumns {
            let x = CGFloat(column) * gridSize
            context?.move(to: CGPoint(x: x, y: 0))
            context?.addLine(to: CGPoint(x: x, y: rect.height))
        }
        
        // Horizontal lines
        for row in 1..<numberOfRows {
            let y = CGFloat(row) * gridSize
            context?.move(to: CGPoint(x: 0, y: y))
            context?.addLine(to: CGPoint(x: rect.width, y: y))
        }
        
        context?.strokePath()
    }
}
