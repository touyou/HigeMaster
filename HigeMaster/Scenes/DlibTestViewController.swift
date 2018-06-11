//
//  DlibTestViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/14.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import Vision

class DlibTestViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.image = image
        }
    }

    var image: UIImage? = #imageLiteral(resourceName: "13653802_1.jpg")
    let wrapper = DlibWrapper()

    override func viewDidLoad() {
        super.viewDidLoad()
        wrapper?.prepare()
    }

    @IBAction func higeButtonTapped() {
        detectFaceLandmark()
    }

    func detectFaceLandmark() {
        let request = VNDetectFaceRectanglesRequest { (request, error) in
            for observation in request.results as! [VNFaceObservation] {
                self.putHige(observation)
            }
        }

        if let cgImage = image?.cgImage {
            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        }
    }

    func putHige(_ observation: VNFaceObservation) {
        let box = observation.boundingBox
        let newBox = CGRect(
            x: box.origin.x * image!.size.width,
            y: (1.0 - box.origin.y - box.size.height) * image!.size.height,
            width: box.size.width * image!.size.width,
            height: box.size.height * image!.size.height)
        guard let faceImage = image?.cgImage?.cropping(to: newBox) else {
            return
        }

        if let pixelBuffer = UIImage(cgImage: faceImage).pixelBuffer(
            width: Int(newBox.size.width),
            height: Int(newBox.size.height),
            pixelFormatType: kCVPixelFormatType_32BGRA,
            colorSpace: CGColorSpaceCreateDeviceRGB(),
            alphaInfo: .noneSkipFirst) {

            if let facePoints = wrapper?.doWork(onPixelBuffer: pixelBuffer) {

                let points = facePoints
                    .map { $0.cgPointValue }
                    .map {
                        CGPoint(x: $0.x + newBox.origin.x, y: $0.y + newBox.origin.y)
                }

                let width = points[166].x - points[178].x
                let height = points[172].y - points[156].y
                let x = points[178].x - width / 2
                let y = points[156].y - height
                UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
                //                let context = UIGraphicsGetCurrentContext()
                image?.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
                #imageLiteral(resourceName: "hige1").draw(in: CGRect(x: x, y: y, width: width * 2, height: height))
                //                context?.setStrokeColor(UIColor.red.cgColor)
                //                context?.setLineWidth(10.0)
                //                context?.move(to: points[0])
                //                for point in points.dropFirst() {
                //                    context?.addLine(to: point)
                //                }
                //                context?.closePath()
                //                context?.strokePath()
                image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()

                self.imageView.image = image
            }
        }
    }

    @IBAction func photoButtonTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
}

extension DlibTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
