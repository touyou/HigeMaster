//
//  ViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/04.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import AVFoundation

final class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var image: UIImage!
    var cameraFlag: Bool = true

    let sessionHandler = SessionHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupCamera(AVCaptureDevice.Position.front)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        for input in session.inputs {
            session.removeInput(input)
        }
        session = nil
        camera = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultView" {
            let viewController = segue.destination as! PreviewViewController
            viewController.image = self.image
        }
    }

    @IBAction func pushCameraBtn() {
        if let connection = output.connection(with: AVMediaType.video) {
            output.captureStillImageAsynchronously(from: connection, completionHandler: {
                (imageDataBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer!)
                self.image = UIImage(data: imageData!)
                self.cropImage()
                self.performSegue(withIdentifier: "toResultView", sender: nil)
            })
        }
    }
    
    @IBAction func pushPickerBtn() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    @IBAction func pushChangeCameraBtn() {
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        for input in session.inputs {
            session.removeInput(input)
        }
        session = nil
        camera = nil
        
        if cameraFlag {
            setupCamera(AVCaptureDevice.Position.back)
            cameraFlag = false
        } else {
            setupCamera(AVCaptureDevice.Position.front)
            cameraFlag = true
        }
    }
    
    func setupCamera(_ position: AVCaptureDevice.Position) {
        // カメラのセットアップ
        sessionHandler.openSession()

        let layer = sessionHandler.layer
        layer.frame = cameraView.bounds

        cameraView.layer.addSublayer(layer)

        view.layoutIfNeeded()

//        session = AVCaptureSession()
//
//        session.sessionPreset = AVCaptureSession.Preset.photo
//
//        for captureDevice in AVCaptureDevice.devices() {
//            if (captureDevice as AnyObject).position == position {
//                camera = captureDevice
//            }
//        }
//
//        do {
//            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        if session.canAddInput(input) {
//            session.addInput(input)
//        }
//
//        output = AVCaptureStillImageOutput()
//        if session.canAddOutput(output) {
//            session.addOutput(output)
//        }
//
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.width))
//        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        cameraView.layer.addSublayer(previewLayer)
//        session.startRunning()
    }
    
    func cropImage() {
        let imgRef = image.cgImage?.cropping(to: CGRect(origin: cameraView.frame.origin, size: CGSize(width: image.size.width, height: image.size.width)))
        image = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "toResultView", sender: nil)
        })
    }
}
