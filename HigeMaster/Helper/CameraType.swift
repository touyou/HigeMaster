//
//  CameraType.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/14.
//  Copyright © 2018 touyou. All rights reserved.
//

import AVFoundation

enum CameraType: Int {
    case back
    case front

    func captureDevice() -> AVCaptureDevice {
        switch self {
        case .front:
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: .video, position: .front).devices
            for device in devices where device.position == .front {
                return device
            }
        default:
            break
        }
        return AVCaptureDevice.default(for: .video)!
    }
}
