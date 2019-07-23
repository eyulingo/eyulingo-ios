//
//  RateControl.swift
//  Eventor
//
//  Created by Rostyslav Kobizsky on 12/17/14.
//  Copyright (c) 2014 Rozdoum. All rights reserved.
//
// Rostmen/RateControl is licensed under the
// Apache License 2.0
//

import UIKit

class RateControl: UIControl {
    
    private let emptyStartSymbol = "☆"
    private let fillStartSymbol  = "★"

    var delegate: ValueChangeDelegate?
    private var label = UILabel()
    var rateMax: Int = 5
    var rate: Int? {
        didSet {
            var resultString = ""
            
            for index in 0..<rateMax {
                resultString += index >= rate! ? emptyStartSymbol : fillStartSymbol
            }
        
            label.text = resultString
                
        }
    }

    override func awakeFromNib() {
        label.frame = self.bounds
        label.textColor = self.tintColor
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 8
        label.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(pan(sender:)))
        panGesture.minimumNumberOfTouches = 1
        label.addGestureRecognizer(panGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(pan(sender:)))

        label.addGestureRecognizer(panGesture)
        label.addGestureRecognizer(tapGesture)
        self.addSubview(label)
        rate = 0
    }
    
    @objc func pan(sender: UIGestureRecognizer) {
        switch sender.state {
        case .changed, .began, .ended:
            let translate = sender.location(in: sender.view!)
            rate = min(max(Int(((translate.x - label.bounds.minX) / label.bounds.size.width) * CGFloat(rateMax + 1)), 1), rateMax)
        default:
            return
        }
        
        delegate?.valueChanged(rate)
    }
    
    override func layoutSubviews() {
        label.font = UIFont.systemFont(ofSize: bounds.size.height * 0.6)
        label.sizeToFit()
        label.center = CGPoint(x: bounds.width / 2.0, y: bounds.height / 2.0)
    }
}

protocol ValueChangeDelegate {
    func valueChanged(_ rate: Int?) -> ()
}
