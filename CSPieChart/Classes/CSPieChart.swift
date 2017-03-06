//
//  CSPieChartViewController.swift
//  Pods
//
//  Created by Youk Chansim on 2017. 1. 5..
//
//

import UIKit

public enum SelectingAnimationType {
    case none
    case piece
    case scaleUp
    case touch
}

public class CSPieChart: UIView {
    
    public var dataSource: CSPieChartDataSource?
    public var delegate: CSPieChartDelegate?
    
    //  Pie chart radius rate that is percentage of frames in the superview
    public var pieChartRadiusRate: CGFloat = 0.7
    
    // Pie chart line length between component and subview
    public var pieChartLineLength: CGFloat = 10
    
    //  This is piechart component selecting animation. default is none
    public var seletingAnimationType: SelectingAnimationType = .none
    
    fileprivate var selectedComponent: CSPieChartComponent?
    
    fileprivate var componentList: [CSPieChartComponent] = []
    
    fileprivate var container = CALayer()
    fileprivate var animated = false
    
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let layers = layer.sublayers else { return }
        guard let component = (layers.flatMap { $0 as? CSPieChartComponent }.filter { $0.containPoint(point: location) }.first) else { return }
        
        if !component.isAnimated {
            component.startAnimation(animationType: seletingAnimationType)
            selectedComponent = component
        } else {
            component.stopAnimation(animationType: seletingAnimationType)
            selectedComponent = nil
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let component = selectedComponent else { return }
        
        if !component.containPoint(point: location) {
            component.stopAnimation(animationType: seletingAnimationType)
            selectedComponent = nil
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else { return }
        guard let component = selectedComponent else { return }
        
        if component.containPoint(point: location) {
            delegate?.didSelectedPieChartComponent?(at: component.index!)
        }
        
        component.stopAnimation(animationType: seletingAnimationType)
        selectedComponent = nil
    }
}

public extension CSPieChart {
    public func show(animated: Bool) {
        clear()
        
        self.animated = animated
        
        if let itemCount = dataSource?.numberOfComponentData() {
            let sum = getTotalValueSum(count: itemCount)
            
            var startAngle: CGFloat = 0
            if itemCount > 0 {
                if let data = dataSource?.pieChartComponentData(at: 0) {
                    startAngle = (sum / data.value).toRadian
                }
            }
            
            for index in 0..<itemCount {
                if let data = dataSource?.pieChartComponentData(at: index) {
                    let degree: Double = data.value / sum * 360
                    let endAngle = startAngle + degree.toRadian
                    
                    let componentColor = getComponentColor(index: index)
                    let lineColor = getLineColor(index: index)
                    let subView = getSubView(index: index)
                    
                    let component = CSPieChartComponent(frame: bounds, startAngle: startAngle, endAngle: endAngle, data: data, index: index, radiusRate: pieChartRadiusRate)
                    component.componentColor = componentColor
                    component.subView = subView?.layer
                    component.lineColor = lineColor
                    component.lineLength = pieChartLineLength
                    component.animate(animated: animated)
                    
                    layer.addSublayer(component)
                    componentList.append(component)
                    
                    startAngle = endAngle
                }
            }
        }
    }
    
    public func reloadPieChart() {
        clear()
        show(animated: animated)
    }
}

fileprivate extension CSPieChart {
    func getTotalValueSum(count: Int) -> Double {
        var sum: Double = 0
        for index in 0..<count {
            if let data = dataSource?.pieChartComponentData(at: index) {
                sum += data.value
            }
        }
        
        return sum
    }
    
    func getComponentColor(index: Int) -> UIColor {
        var componentColor: UIColor = .white
        if let componentColorsCount = dataSource?.numberOfComponentColors() {
            let compoenetColorIndex = index % componentColorsCount
            componentColor = dataSource?.pieChartComponentColor(at: compoenetColorIndex) ?? .white
        }
        
        return componentColor
    }
    
    func getLineColor(index: Int) -> UIColor {
        var lineColor: UIColor = .black
        if let lineColorsCount = dataSource?.numberOfLineColors?() {
            let lineColorIndex = index % lineColorsCount
            lineColor = dataSource?.pieChartLineColor?(at: lineColorIndex) ?? .black
        }
        
        return lineColor
    }
    
    func getSubView(index: Int) -> UIView? {
        var subView: UIView?
        if let subViewsCount = dataSource?.numberOfComponentSubViews?() {
            let subViewIndex = index % subViewsCount
            subView = dataSource?.pieChartComponentSubView?(at: subViewIndex)
        }
        
        return subView
    }
    
    func clear() {
        layer.sublayers?.removeAll()
        componentList.removeAll()
    }
}
