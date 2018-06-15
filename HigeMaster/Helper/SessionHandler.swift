//
//  SessionHandler.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/11.
//  Copyright © 2018 touyou. All rights reserved.
//

import AVFoundation

class SessionHandler: NSObject {

    var session = AVCaptureSession()

    let layer = AVSampleBufferDisplayLayer()
    let sampleQueue = DispatchQueue(label: "com.dev.touyou.HigeMaster.sampleQueue")
    let faceQueue = DispatchQueue(label: "com.dev.touyou.HigeMaster.faceQueue")
    let wrapper = DlibWrapper()

    var currentMetadata: [Any]

    override init() {
        currentMetadata = []
        super.init()
    }

    func openSession() {
        // TODO: 写真モードの時に対応...?
        let device = AVCaptureDevice.devices(for: .video)
            .map { $0 }
            .filter { $0.position == .front }
            .first!

        let input = try! AVCaptureDeviceInput(device: device)

        let output = AVCaptureVideoDataOutput()
        output.setSampleBufferDelegate(self, queue: sampleQueue)

        let metaOutput = AVCaptureMetadataOutput()
        metaOutput.setMetadataObjectsDelegate(self, queue: faceQueue)

        // MARK: Session Configuration
        session.beginConfiguration()

        if session.canAddInput(input) {
            session.addInput(input)
        }
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        if session.canAddOutput(metaOutput) {
            session.addOutput(metaOutput)
        }

        session.commitConfiguration()

        let settings: [AnyHashable: Any] = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA]
        output.videoSettings = settings as! [String: Any]

        metaOutput.metadataObjectTypes = [.face]

        wrapper?.prepare()

        session.startRunning()
    }

}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension SessionHandler: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {

        if !currentMetadata.isEmpty {
            let boundsArray = currentMetadata
                .compactMap { $0 as? AVMetadataFaceObject }
                .map { (faceObject) -> NSValue in
                    let convertedObject = output.transformedMetadataObject(for: faceObject, connection: connection)
                    return NSValue(cgRect: convertedObject!.bounds)
            }

            let facePoints = wrapper?.doWork(on: sampleBuffer, inRects: boundsArray)
            // TODO: facePointsの中のひげ相当の部分にひげを描画
            print(facePoints!)
        }

        layer.enqueue(sampleBuffer)
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("DidDropSampleBuffer")
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension SessionHandler: AVCaptureMetadataOutputObjectsDelegate {

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        currentMetadata = metadataObjects as [Any]
    }
}
