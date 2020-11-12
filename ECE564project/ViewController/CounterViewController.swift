//
//  CounterViewController.swift
//  ECE564project
//
//  Created by 杨越 on 11/9/20.
//  Copyright © 2020 杨越. All rights reserved.
//

import UIKit

class CounterViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, CAAnimationDelegate{

    var circlePath: UIBezierPath!
    let foreProgressLayer = CAShapeLayer()
    let backProgressLayer = CAShapeLayer()
    let animation = CABasicAnimation(keyPath: "strokeEnd")
    var isAniationStarted = false
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    var selectPickerIndex = 0
    
    var timer = Timer()
    var time:Int = 0
    var timerMode: TimerMode = .initial
    let availableMinutes = Array(1...60)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        setCirclePath()
        createBackProgressLayer()
        //createForeProgressLayer()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - set up timer
    @IBAction func controlTimer(_ sender: Any) {
        if(timerMode == .initial){
            if(time != 0){
                createForeProgressLayer()
                startResumeAnimation()
                startTimer()
                timerMode = .running
                startButton.setTitle("Pause", for: .normal)
                startButton.setTitleColor(UIColor.orange, for: .normal)
                pickerView.isHidden = true
            }
        }
        else{
            pauseAnimation()
            timer.invalidate()
            timerMode = .initial
            startButton.setTitle("Start", for: .normal)
            startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        stopAnimation()
        timer.invalidate()
        timerMode = .initial
        time = 0
        timeLabel.text = "00:00"
        startButton.setTitle("Start", for: .normal)
        startButton.setTitleColor(UIColor.outlineStrokeColor, for: .normal)
        pickerView.isHidden = false
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer(){
        if(time <= 0){
            timer.invalidate()
            time = 0
            timerMode = .initial
            timeLabel.text = "0"
            startButton.setTitle("start", for: .normal)
        }
        time -= 1
        timeLabel.text = formatTime(time: time)
    }
    
    func formatTime(time: Int)->String{
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i", minutes, seconds)
    }
    
    // MARK: - set progress animation
    
    func setCirclePath(){
        circlePath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2*CGFloat.pi, clockwise: true)
    }
    
    // draw progress circle background circle
    func createBackProgressLayer(){
        backProgressLayer.path = circlePath.cgPath
        backProgressLayer.strokeColor = UIColor.trackStrokeColor.cgColor
        backProgressLayer.lineWidth = 20
        backProgressLayer.fillColor = UIColor.clear.cgColor
        backProgressLayer.lineCap = .round
        backProgressLayer.position = view.center
        
        view.layer.addSublayer(backProgressLayer)
    }
        
     // draw progress circle foreground circle
    func createForeProgressLayer() {
        foreProgressLayer.path = circlePath.cgPath
        foreProgressLayer.strokeColor = UIColor.outlineStrokeColor.cgColor
        foreProgressLayer.lineWidth = 20
        foreProgressLayer.fillColor = UIColor.clear.cgColor
        foreProgressLayer.lineCap = .round
        foreProgressLayer.position = view.center
        foreProgressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi/2, 0, 0, 1)
        
//        foreProgressLayer.strokeEnd = 0
        
        view.layer.addSublayer(foreProgressLayer)
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(process)))
    }
    
    func startResumeAnimation(){
        if(!isAniationStarted){
            startAnimation()
        }
        else{
            resumeAnimation()
        }
    }
    
    func startAnimation() {
        resetAnimation()
        foreProgressLayer.strokeEnd = 0.0
        animation.keyPath = "strokeEnd"
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = CFTimeInterval(time)
        animation.delegate = self
        animation.isRemovedOnCompletion = false
        animation.isAdditive = true
        animation.fillMode = CAMediaTimingFillMode.forwards
        foreProgressLayer.add(animation, forKey: "strokeEnd")
        isAniationStarted = true
    
    }
    
    func pauseAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 0.0
        foreProgressLayer.timeOffset = pausedTime
    }
    
    func resumeAnimation(){
        let pausedTime = foreProgressLayer.convertTime(CACurrentMediaTime(), from: nil)
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        let timeSincePaused = foreProgressLayer.convertTime(CACurrentMediaTime(), from:nil) - pausedTime
        foreProgressLayer.beginTime = timeSincePaused
    }
    
    func resetAnimation() {
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        isAniationStarted = false
    }
    
    func stopAnimation(){
        foreProgressLayer.speed = 1.0
        foreProgressLayer.timeOffset = 0.0
        foreProgressLayer.beginTime = 0.0
        foreProgressLayer.strokeEnd = 0.0
        foreProgressLayer.removeAllAnimations()
        isAniationStarted = false
    }
    
    internal func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        stopAnimation()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

     // MARK: - set up pickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        let res: String = "\(availableMinutes[row]) min"
//        time = availableMinutes[row] * 60
//        return res
//    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let res: String = "\(availableMinutes[row]) min"
        time = availableMinutes[row] * 60
        return NSAttributedString(string: res, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return availableMinutes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        timeLabel.text = formatTime(time: availableMinutes[row] * 60)
    }
}
