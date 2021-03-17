//
//  SDebounce.swift
//  SThrottle
//
//  Created by Simon on 2021/3/17.
//

/**
 防抖
 */
import UIKit

class SDebounce: NSObject {
    enum SDebounceMode {
        case leading
        case trailing
    }
    
    typealias  Task = () -> Void
    private var mode: SDebounceMode = .leading
    var interval: TimeInterval = 0
    var task: Task?
    var queue: DispatchQueue = DispatchQueue.main
    var block: DispatchWorkItem?
    var lastCallTaskDate: Date?
    
    init(mode: SDebounceMode = .leading, interval: TimeInterval = 1, onQueue: DispatchQueue = .main, task: @escaping Task) {
        self.mode = mode
        self.interval = interval < 0 ? 0.1 : interval
        self.task = task
        self.queue = onQueue
    }
    
    func call() {
        switch mode {
        case .leading:
            leadingCall()
        case .trailing:
            trailingCall()
        }
    }
    
    func invalidate() {
        self.task = nil
        self.block = nil
    }
    
    private func trailingCall() {
        if self.block != nil {
            self.block?.cancel()
        }
        self.block = DispatchWorkItem(flags: .inheritQoS, block: {
            if self.task != nil {
                self.task!()
            }
        })
        queue.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(self.interval * 1000)), execute: self.block!)
    }
    
    private func leadingCall() {
        if self.lastCallTaskDate != nil {
            if Date().timeIntervalSince(self.lastCallTaskDate!) > self.interval {
                self.runTaskDirectly()
            }
        }else {
            self.runTaskDirectly()
        }
        self.lastCallTaskDate = Date()
    }
    
    private func runTaskDirectly() {
        self.queue.async {
            if self.task != nil {
                self.task!()
            }
        }
    }
}
