//
//  DeviceView.swift
//  Perpective Transform
//
//  Created by k2 tam on 29/08/2023.
//

import UIKit

class DeviceView: UIView {
    let kCONTENT_XIB_NAME = "DeviceView"

    @IBOutlet var contentView: UIView!
    
    
    @IBOutlet weak var deviceImageView: UIImageView!
    @IBOutlet weak var deviceStatusView: UIView!
    @IBOutlet weak var deviceLabelView: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
        deviceStatusView.layer.cornerRadius = deviceStatusView.bounds.height / 2
        deviceStatusView.clipsToBounds = true
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self)
        contentView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func configure(from device: Device){
        deviceImageView.image =  UIImage(named: device.deviceImg.rawValue)
        
        deviceLabelView.text = device.name
        getWidthThatFitTextInLabel(label: deviceLabelView)
        
        switch device.status {
        case .green:
            deviceStatusView.backgroundColor = .green
        case .yellow:
            deviceStatusView.backgroundColor = .yellow
        case .red:
            deviceStatusView.backgroundColor = .green
        }
    }
    
    
    // Calculate the width that fits the label's content
    private func getWidthThatFitTextInLabel(label: UILabel) {
        let fittingSize = label.intrinsicContentSize
        let widthThatFits = fittingSize.width
        
        contentView.frame.size.width = widthThatFits + 50

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
}


extension UIView
{
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
}
