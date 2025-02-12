//
//  MotionManager.swift
//  Teammates
//
//  Created by Sachin Gurung on 2/12/25.
//

import Foundation
import CoreMotion

class MotionManager: ObservableObject {
    private let motionManager = CMMotionManager()
    
    @Published var didShake = false

    init() {
        startMotionUpdates()
    }

    private func startMotionUpdates() {
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] (data, error) in
            guard let data = data else { return }
            
            // Detect shake based on acceleration threshold
            let accelerationThreshold: Double = 2.5
            if abs(data.acceleration.x) > accelerationThreshold ||
               abs(data.acceleration.y) > accelerationThreshold ||
               abs(data.acceleration.z) > accelerationThreshold {
                DispatchQueue.main.async {
                    self?.didShake = true
                }
            }
        }
    }
}
