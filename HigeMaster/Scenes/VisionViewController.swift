//
//  VisionViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/14.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Vision

class VisionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {

            imageView.image = image
        }
    }

    var image: UIImage? = #imageLiteral(resourceName: "13653802_1.jpg")

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func higeButtonTapped() {
        detectFaceLandmark()
    }

    @IBAction func openPhotoButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    func detectFaceLandmark() {
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            for observation in request.results as! [VNFaceObservation] {
                self.putHige(observation)
            }
        }

        if let cgImage = image?.cgImage {
            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        }
    }

    func putHige(_ observation: VNFaceObservation) {
        guard let mouse = observation.landmarks?.outerLips else {
            return
        }
        guard let allPoints = observation.landmarks?.allPoints?.pointsInImage(imageSize: image!.size) else {
            return
        }
        let facePoints = allPoints.map {
            CGPoint(x: $0.x, y: image!.size.height - $0.y)
        }
        let points = mouse.pointsInImage(imageSize: image!.size).map {
            CGPoint(x: $0.x, y: image!.size.height - $0.y)
        }
        let width = points[5].x - points[0].x
        let height = points[3].y - points[7].y
        let x = points[0].x - width / 2
        let y = points[3].y + height / 2
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
//        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        #imageLiteral(resourceName: "hige1").draw(in: CGRect(x: x, y: y, width: width * 2, height: height))
//        context?.setStrokeColor(UIColor.red.cgColor)
//        context?.setLineWidth(10.0)
//        context?.move(to: facePoints[0])
//        for point in facePoints.dropFirst() {
//            context?.addLine(to: point)
//        }
//        context?.closePath()
//        context?.strokePath()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageView.image = image
    }
}

extension VisionViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
