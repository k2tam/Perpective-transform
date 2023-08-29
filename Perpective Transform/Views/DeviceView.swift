//
//  DeviceView.swift
//  Perpective Transform
//
//  Created by k2 tam on 29/08/2023.
//

import UIKit

class DeviceView: UIView {
    
    
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceStatusView: UIView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
  
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
