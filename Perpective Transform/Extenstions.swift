//
//  Extenstions.swift
//  Perpective Transform
//
//  Created by k2 tam on 31/08/2023.
//

import UIKit


extension UIView {
    func addSubViews(_ views: UIView...){
        views.forEach {
            addSubview($0)
        }
    }
}
