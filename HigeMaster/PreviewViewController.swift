//
//  PreviewViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/21.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import ProjectOxfordFace

class PreviewViewController: UIViewController {
    
    @IBOutlet weak var previewImageView: UIImageView!
    
    var indicatorView: UIActivityIndicatorView!
    var image: UIImage!
    var faces = [MPOFace]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if image != nil {
            previewImageView.image = image
        }
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        self.navigationItem.hidesBackButton = true
        
        indicatorView = UIActivityIndicatorView()
        indicatorView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        indicatorView.center = view.center
        indicatorView.hidesWhenStopped = false
        indicatorView.activityIndicatorViewStyle = .whiteLarge
        indicatorView.backgroundColor = UIColor.gray
        indicatorView.layer.masksToBounds = true
        indicatorView.layer.cornerRadius = 5.0
        indicatorView.layer.opacity = 0.8
        view.addSubview(indicatorView)
        indicatorView.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    @IBAction func pushOkBtn() {
        indicatorView.startAnimating()
        indicatorView.isHidden = false
        runDetection(image)
    }
    
    @IBAction func pushCancelBtn() {
        _ = navigationController?.popViewController(animated: true)
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
            self.indicatorView.stopAnimating()
            self.indicatorView.isHidden = true
            if let e = error {
                print(e)
            } else {
                self.faces = collection ?? []
                self.performSegue(withIdentifier: "toEditView", sender: nil)
            }
        })
    }
}
