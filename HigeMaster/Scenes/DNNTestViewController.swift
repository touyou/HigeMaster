//
//  DNNTestViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2018/06/14.
//  Copyright © 2018 touyou. All rights reserved.
//

import UIKit
import CoreML
import Vision

class DNNTestViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView! {
        didSet {

            imageView.image = image
        }
    }

    var image: UIImage? = #imageLiteral(resourceName: "13653802_1.jpg")
    let model = dnn_face()

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

        var img = CIImage(cgImage: faceImage)
        let scale = 100.0 / CGFloat(faceImage.width)
        let trans = CGAffineTransform(scaleX: scale, y: scale)
        img = img.transformed(by: trans)
        let img2 = UIImage(ciImage: img).safeCgImage

        let data = img2?.dataProvider!.data
        let length = CFDataGetLength(data)
        var rawData = [UInt8](repeating: 0, count: length)
        CFDataGetBytes(data, CFRange(location: 0, length: length), &rawData)
        do {
            let mlarr = try MLMultiArray(shape: [1, 100, 100], dataType: .double)
            let count = rawData.count
            var j = 0
            for i in 0 ..< count {
                if i % (count / 100 * 100) == 0 {
                    mlarr[j] = NSNumber(value: Double(255 - Int(rawData[i])) / 255.0)
                    j += 1
                }
            }
            let output = try model.prediction(image: mlarr)
            drawHige(output.parts, newBox)
        } catch {
            print(error)
        }
    }


    func drawHige(_ parts: MLMultiArray, _ box: CGRect) {
        var points: [CGPoint] = []

        for i in 0 ..< 194 {
            let x = CGFloat(parts[i * 2].doubleValue) * box.size.width + box.origin.x
            let y = CGFloat(parts[i * 2 + 1].doubleValue) * box.size.height + box.origin.y
            points.append(CGPoint(x: x, y: y))
        }

        let width = points[166].x - points[178].x
        let height = points[172].y - points[156].y
        let x = points[178].x - width / 2
        let y = points[156].y - height
        UIGraphicsBeginImageContextWithOptions(image!.size, false, 0.0)
        //        let context = UIGraphicsGetCurrentContext()
        image?.draw(in: CGRect(x: 0, y: 0, width: image!.size.width, height: image!.size.height))
        #imageLiteral(resourceName: "hige1").draw(in: CGRect(x: x, y: y, width: width * 2, height: height))
        //        context?.setStrokeColor(UIColor.red.cgColor)
        //        context?.setLineWidth(10.0)
        //        context?.move(to: points[0])
        //        for point in points.dropFirst() {
        //            context?.addLine(to: point)
        //        }
        //        context?.closePath()
        //        context?.strokePath()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageView.image = image
    }
}

extension DNNTestViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {
    var safeCiImage: CIImage? {
        return self.ciImage ?? CIImage(image: self)
    }

    var safeCgImage: CGImage? {
        if let cgImage = self.cgImage {
            return cgImage
        }
        if let ciImage = safeCiImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }
        return nil
    }
}
