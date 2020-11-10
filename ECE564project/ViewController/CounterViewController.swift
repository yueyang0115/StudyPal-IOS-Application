//
//  CounterViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/9/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    var circlePath: UIBezierPath!
    
    let shapeLayer = CAShapeLayer()
    var pulsatingLayer = CAShapeLayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setCirclePath()
        //createPulsatingLayer()
        createBackgroundLayer()
        createShapeLayer()
        //view.addSubview(timeLabel)
        // Do any additional setup after loading the view.
    }
    
    
    func setCirclePath(){
        circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    }
    
    func createBackgroundLayer(){
        let backgroundLayer = CAShapeLayer()
        
        backgroundLayer.path = circlePath.cgPath
        backgroundLayer.strokeColor = UIColor.trackStrokeColor.cgColor
        backgroundLayer.lineWidth = 20
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.position = view.center
        
        view.layer.addSublayer(backgroundLayer)
    }
    
    func createPulsatingLayer(){
        //pulsatingLayer = CAShapeLayer()
        pulsatingLayer.path = circlePath.cgPath
        pulsatingLayer.strokeColor = UIColor.gray.cgColor
        pulsatingLayer.lineWidth = 10
        pulsatingLayer.fillColor = UIColor.pulsatingFillColor.cgColor
        pulsatingLayer.lineCap = .round
        pulsatingLayer.position = view.center
        
        view.layer.addSublayer(pulsatingLayer)
        animatePulsatingLayer()
    }
    func animatePulsatingLayer(){
        print("try scale")
        let animation = CABasicAnimation(keyPath: "transform.scale")
        
        animation.toValue = 1.3
        animation.duration = 0.8
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.autoreverses = true
        animation.repeatCount = Float.infinity

        pulsatingLayer.add(animation, forKey: "pulsing")
    }
    
    func createShapeLayer() {
        shapeLayer.path = circlePath.cgPath
        shapeLayer.strokeColor = UIColor.outlineStrokeColor.cgColor
        shapeLayer.lineWidth = 20
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        shapeLayer.position = view.center
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(process)))
    }
    
    func beginCounter(){
        print("trying to count down")
        shapeLayer.strokeEnd = 0

    }
    
    @objc private func process(){
        print("try to animate stroke")
        beginCounter()
        animateCircle()
    }
    
    func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
