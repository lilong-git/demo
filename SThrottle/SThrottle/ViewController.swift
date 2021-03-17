//
//  ViewController.swift
//  SThrottle
//
//  Created by Simon on 2021/3/17.
//

/**
 函数节流和防抖: https://mp.weixin.qq.com/s/h1MYGTYtYo9pcHmqw6tHBw
 
 */

import UIKit


class ViewController: UIViewController {

    var throttle: SThrottle?
    var debounce: SDebounce?
    var throttleClickCount: Int = 0
    var throttleCallCount: Int = 0
    var debounceClickCount: Int = 0
    var debounceCallCount: Int = 0
    var throttleLabel: UILabel?
    var debounceLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        throttleLabel = UILabel(frame: CGRect(x: 50, y: 100, width: 200, height: 50))
        throttleLabel?.backgroundColor = .cyan
        throttleLabel?.textAlignment = .center
        view.addSubview(throttleLabel!)
        throttleLabel!.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(50);
            make.right.equalToSuperview().offset(-50);
            make.top.equalToSuperview().offset(100);
            make.height.equalTo(50)
        })
        
        let throttleBtn = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 50))
        throttleBtn.setTitle("节流点击", for: .normal)
        throttleBtn.addTarget(self, action: #selector(throttleClick), for: .touchUpInside)
        throttleBtn.backgroundColor = .red
        view.addSubview(throttleBtn)
        throttleBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(100);
            make.right.equalToSuperview().offset(-100);
            make.top.equalTo(throttleLabel!.snp.bottom).offset(20.0)
        }
        
        
        debounceLabel = UILabel(frame: CGRect(x: 50, y: 100, width: 200, height: 50))
        debounceLabel?.backgroundColor = .cyan
        debounceLabel?.textAlignment = .center
        view.addSubview(debounceLabel!)
        debounceLabel!.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(50);
            make.right.equalToSuperview().offset(-50);
            make.top.equalTo(throttleBtn.snp.bottom).offset(100)
            make.height.equalTo(50)
        })
        
        let debounceBtn = UIButton(frame: CGRect(x: 100, y: 300, width: 100, height: 50))
        debounceBtn.setTitle("防抖点击", for: .normal)
        debounceBtn.addTarget(self, action: #selector(debounceClick), for: .touchUpInside)
        debounceBtn.backgroundColor = .red
        view.addSubview(debounceBtn)
        debounceBtn.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(50);
            make.right.equalToSuperview().offset(-50);
            make.top.equalTo(debounceLabel!.snp.bottom).offset(50)
            make.height.equalTo(50)
        })
    }
    
    @objc func throttleClick() {
        if self.throttle == nil {
            self.throttle = SThrottle(mode: .trailing, interval: 1, task: {
                self.throttleCallCount += 1
                self.throttleLabel?.text = "节流:\(self.throttleClickCount)=====\(self.throttleCallCount)"
            })
        }
        self.throttle?.call()
        self.throttleClickCount += 1
        throttleLabel?.text = "节流:\(self.throttleClickCount)=====\(self.throttleCallCount)"
    }
    
    @objc func debounceClick() {
        if self.debounce == nil {
            self.debounce = SDebounce(mode: .leading, interval: 1, task: {
                self.debounceCallCount += 1
                self.debounceLabel?.text = "防抖:\(self.debounceClickCount)====\(self.debounceCallCount)"
            })
        }
        self.debounce?.call()
        self.debounceClickCount += 1
        self.debounceLabel?.text = "防抖:\(self.debounceClickCount)====\(self.debounceCallCount)"
    }
}

