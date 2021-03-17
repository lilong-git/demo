//
//  SThrottle.swift
//  SThrottle
//
//  Created by Simon on 2021/3/17.
//
/**
 节流
 */
import UIKit

class SThrottle: NSObject {
    public enum SThrottleMode {
        case leading
        case trailing
    }
    typealias  Task = () -> Void
    private var mode: SThrottleMode = .leading
    var interval: TimeInterval = 0
    var task: Task?
    var queue: DispatchQueue = DispatchQueue.main
    var lastRunTaskDate: Date?
    var nextRunTaskDate: Date?
    
    init(mode: SThrottleMode = .leading, interval: TimeInterval = 1, onQueue: DispatchQueue = .main, task: @escaping Task) {
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
        task = nil
    }
    
    private func leadingCall() {
        guard self.lastRunTaskDate != nil else {
            leadingRunTaskDirectly()
            return
        }
        if Date().timeIntervalSince(self.lastRunTaskDate!) > interval {
            leadingRunTaskDirectly()
        }
    }
    private func leadingRunTaskDirectly() {
        queue.async {
            if self.task != nil {
                self.task!()
            }
            self.lastRunTaskDate = Date()
        }
    }
    
    
    
    private func trailingCall() {
        let now = Date()
        guard nextRunTaskDate == nil else {
            return
        }
        if lastRunTaskDate == nil {
            nextRunTaskDate = Date(timeInterval: interval, since: now)
        }else {
            if now.timeIntervalSince(lastRunTaskDate!) > interval {
                nextRunTaskDate = Date(timeInterval: interval, since: now)
            }else {
                nextRunTaskDate = Date(timeInterval: interval, since: lastRunTaskDate!)
            }
        }
        
        let nextInterval = nextRunTaskDate?.timeIntervalSince(now)
        queue.asyncAfter(deadline: DispatchTime.now() + .milliseconds(Int(nextInterval! * 1000))) {
            if self.task != nil {
                self.task!()
            }
            self.lastRunTaskDate = Date()
            self.nextRunTaskDate = nil
        }
    }
}

