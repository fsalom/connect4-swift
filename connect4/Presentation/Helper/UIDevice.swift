//
//  UIDevice.swift
//  connect4
//
//  Created by Fernando Salom Carratala on 25/12/22.
//

import AVFoundation
import UIKit

extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
