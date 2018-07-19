//
//  CameraHelper.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/07/19.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import AVFoundation

final class CameraHelper: NSObject {

    let imageOutput = AVCapturePhotoOutput()
    var completion: ((UIImage) -> Void)!

    func findDevice(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {

        return AVCaptureDevice.default(.builtInWideAngleCamera,
                                       for: .video,
                                       position: position)
    }

    func createView(_ session: AVCaptureSession?, _ device: AVCaptureDevice?) -> AVCaptureVideoPreviewLayer? {

        guard let device = device else {

            return nil
        }
        guard let session = session else {

            return nil
        }

        let videoInput = try! AVCaptureDeviceInput(device: device)
        if session.canAddInput(videoInput) {
            session.addInput(videoInput)
        }
        if session.canAddOutput(imageOutput) {
            session.addOutput(imageOutput)
        }
        return AVCaptureVideoPreviewLayer(session: session)
    }

    func takePhoto(_ completion: @escaping (UIImage) -> Void) {

        self.completion = completion
        imageOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
    }
}

extension CameraHelper: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {

        if let error = error {
            print(error)
            return
        }

        if let data = photo.fileDataRepresentation() {

            completion(UIImage(data: data)!)
        }
    }
}

/// https://ja.stackoverflow.com/questions/34466/avcapturephotocapturedelegate%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%97%E3%81%A6%E6%92%AE%E5%BD%B1%E3%81%97%E3%81%9F%E7%94%BB%E5%83%8F%E3%82%92%E6%AD%A3%E6%96%B9%E5%BD%A2%E3%81%AB%E3%81%97%E3%81%9F%E3%81%84
extension UIImage {
    func croppingCenterSquare() -> UIImage {
        let cgImage = self.cgImage!
        var newWidth = CGFloat(cgImage.width)
        var newHeight = CGFloat(cgImage.height)
        if newWidth > newHeight {
            newWidth = newHeight
        } else {
            newHeight = newWidth
        }
        let x = (CGFloat(cgImage.width) - newWidth) / 2
        let y = (CGFloat(cgImage.height) - newHeight) / 2
        let rect = CGRect(x: x, y: y, width: newWidth, height: newHeight)
        let croppedCGImage = cgImage.cropping(to: rect)!
        return UIImage(cgImage: croppedCGImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
