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

    let session = AVCaptureSession()
    let cameraHelper = CameraHelper()
    var image: UIImage!
    var cameraFlag: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupCamera(AVCaptureDevice.Position.back)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // camera stop メモリ解放
        session.stopRunning()
        
        for output in session.outputs {
            session.removeOutput(output)
        }
        
        for input in session.inputs {
            session.removeInput(input)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "toResultView" {

            let viewController = segue.destination as! PreviewViewController
            viewController.image = self.image
        }
    }

    @IBAction func pushCameraBtn() {

        cameraHelper.takePhoto { image in

            self.image = image
            self.cropImage()
            self.performSegue(withIdentifier: "toResultView", sender: nil)
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

        if cameraFlag {
            setupCamera(.back)
            cameraFlag = false
        } else {
            setupCamera(.front)
            cameraFlag = true
        }
    }
    
    func setupCamera(_ position: AVCaptureDevice.Position) {

        let device = cameraHelper.findDevice(position)

        if let videoLayer = cameraHelper.createView(session, device) {

            videoLayer.frame = cameraView.bounds
            videoLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(videoLayer)
        } else {
            fatalError("cannot setup layer")
        }

        session.startRunning()
    }
    
    func cropImage() {
        image = image.croppingCenterSquare()
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        picker.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "toResultView", sender: nil)
        })
    }
}
