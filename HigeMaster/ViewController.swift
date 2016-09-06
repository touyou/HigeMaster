//
//  ViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/04.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import ProjectOxfordFace
//import AnyObjectConvertible
//
//extension UInt32: AnyObjectConvertible {}

final class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pushDetectBtn() {
        let actionSheet = UIAlertController(title: "Select a photo.", message: nil, preferredStyle: .ActionSheet)
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { action in
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        }))
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { action in
            picker.sourceType = .PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        }))

        presentViewController(actionSheet, animated: true, completion: nil)
    }

    func runDetection(image: UIImage) {
        let client: MPOFaceServiceClient = MPOFaceServiceClient(subscriptionKey: ProjectOxfordFaceSubscriptionKey)
        let data: NSData = UIImagePNGRepresentation(image)!

        print("run")

        client.detectWithData(data, returnFaceId: true, returnFaceLandmarks: true, returnFaceAttributes: [NSNumber(unsignedInt: MPOFaceAttributeTypeFacialHair.rawValue)], completionBlock: { collection, error in
            for face in collection {
                print("id: \(face.faceId) --------------------------------")
                print("beard: \(face.attributes.facialHair.beard)")
                print("sideBurns: \(face.attributes.facialHair.sideburns)")
                print("mustache: \(face.attributes.facialHair.mustache)")
            }
        })
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        runDetection(image)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
}
