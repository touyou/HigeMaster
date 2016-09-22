//
//  ViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/04.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import AVFoundation
import ProjectOxfordFace

final class ViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    
    var input:AVCaptureDeviceInput!
    var output:AVCaptureStillImageOutput!
    var session:AVCaptureSession!
    var camera:AVCaptureDevice!
    var image: UIImage!
    var cameraFlag: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupCamera(AVCaptureDevicePosition.front)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
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
        if let connection = output.connection(withMediaType: AVMediaTypeVideo) {
            output.captureStillImageAsynchronously(from: connection, completionHandler: {
                (imageDataBuffer, error) -> Void in
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataBuffer)
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
            session.removeOutput(output as? AVCaptureOutput)
        }
        
        for input in session.inputs {
            session.removeInput(input as? AVCaptureInput)
        }
        session = nil
        camera = nil
        
        if cameraFlag {
            setupCamera(AVCaptureDevicePosition.back)
            cameraFlag = false
        } else {
            setupCamera(AVCaptureDevicePosition.front)
            cameraFlag = true
        }
    }
    
    func runDetection(_ image: UIImage) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient(subscriptionKey: ProjectOxfordFaceSubscriptionKey)
        let data: Data = UIImagePNGRepresentation(image)!

        print("run")

        client.detect(with: data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [NSNumber(value: MPOFaceAttributeTypeFacialHair.rawValue as UInt32)], completionBlock: { collection, error in
            for face in collection! {
                print("id: \(face.faceId) --------------------------------")
                print("beard: \(face.attributes.facialHair.beard)")
                print("sideBurns: \(face.attributes.facialHair.sideburns)")
                print("mustache: \(face.attributes.facialHair.mustache)")
            }
        })
    }
    
    func setupCamera(_ position: AVCaptureDevicePosition) {
        // カメラのセットアップ
        session = AVCaptureSession()
        
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        for captureDevice in AVCaptureDevice.devices() {
            if (captureDevice as AnyObject).position == position {
                camera = captureDevice as? AVCaptureDevice
            }
        }
        
        do {
            input = try AVCaptureDeviceInput(device: camera) as AVCaptureDeviceInput
        } catch let error {
            print(error.localizedDescription)
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        output = AVCaptureStillImageOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = CGRect(origin: self.view.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.width))
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        cameraView.layer.addSublayer(previewLayer!)
        session.startRunning()
    }
    
    func cropImage() {
        let imgRef = image.cgImage?.cropping(to: CGRect(origin: cameraView.frame.origin, size: CGSize(width: image.size.width, height: image.size.width)))
        image = UIImage(cgImage: imgRef!, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        self.image = image
        runDetection(image)
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "toResultView", sender: nil)
        })
    }
}
