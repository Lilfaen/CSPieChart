//
//  Double+Extension.swift
//  Pods
//
//  Created by Youk Chansim on 2017. 1. 5..
//
//

import Foundation

extension Double {
    var toRadian: CGFloat {
        return CGFloat(self * (Double.pi / 180))
    }
}
