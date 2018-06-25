//
//  EditViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/23.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import Vision

final class EditViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var manualBtn: UIButton!
    @IBOutlet weak var autoBtn: UIButton!
    @IBOutlet weak var sizeSlider: UISlider!
    
    var image: UIImage!
    var mode: Int!
    var higeImages: [UIImage]!
    var selectedHige: UIImage!
    var sizeRatio: CGFloat = 1.0
    var autoImageRect = [CGRect]()
    var manualStampViews = [UIImageView]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.titleView = UIImageView(image: UIImage(named: "logo"))
        
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = collectionLayout
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.delegate = self

        if image != nil {
            imageView.image = image
        }
        
        higeImages = [#imageLiteral(resourceName: "hige1"), #imageLiteral(resourceName: "hige2"), #imageLiteral(resourceName: "hige3")]
        selectedHige = higeImages[0]
        
        initSlider()
        
        setAutoMode()
        
        putStamp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            for imgView in manualStampViews {
                if imgView.frame.contains(touch.previousLocation(in: imageView)) {
                    let prev = touch.previousLocation(in: imageView)
                    let dest = touch.location(in: imageView)
                    var rect = imgView.frame
                    rect.origin.x += dest.x - prev.x
                    rect.origin.y += dest.y - prev.y
                    imgView.frame = rect
                    imageView.addSubview(imgView)
                }
            }
        }
    }
    
    @IBAction func pushCancelBtn() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func pushShareBtn() {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, 0.0)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let shareImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let activityItems = [shareImage]
        let activityViewCtrl = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        let excludedActivityTypes = [UIActivityType.postToWeibo, UIActivityType.postToTencentWeibo]
        activityViewCtrl.excludedActivityTypes = excludedActivityTypes
        // for iPad
        activityViewCtrl.popoverPresentationController?.sourceView = view
        activityViewCtrl.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 20, height: 20)
        present(activityViewCtrl, animated: true, completion: nil)
    }
    
    @IBAction func pushAutoBtn() {
        setAutoMode()
    }
    
    @IBAction func pushManualBtn() {
        setManualMode()
    }
    
    func putStamp() {
        if mode == 0 {
            detectFaceLandmark()
        }
    }

    func detectFaceLandmark() {
        let request = VNDetectFaceLandmarksRequest { (request, error) in
            for observation in request.results as! [VNFaceObservation] {
                self.putHige(observation)
            }
        }

        if let cgImage = image.cgImage {
            try? VNImageRequestHandler(cgImage: cgImage, options: [:]).perform([request])
        }
    }

    func putHige(_ observation: VNFaceObservation) {
        guard let mouse = observation.landmarks?.outerLips else {
            return
        }
        let points = mouse.pointsInImage(imageSize: image.size).map {
            CGPoint(x: $0.x, y: image.size.height - $0.y)
        }
        let width = points[5].x - points[9].x
        let height = (points[7].y - points[2].y) / 2.0
        let x = points[2].x
        let y = points[2].y - height
        autoImageRect.append(CGRect(x: x, y: y, width: width, height: height))
        drawAutoImage()
    }
    
    func setAutoMode() {
        manualBtn.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        manualBtn.setTitleColor(#colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1), for: .normal)
        autoBtn.backgroundColor = #colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1)
        autoBtn.setTitleColor(#colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1), for: .normal)
        sizeSlider.value = 0.5
        mode = 0
    }
    
    func setManualMode() {
        manualBtn.backgroundColor = #colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1)
        manualBtn.setTitleColor(#colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1), for: .normal)
        autoBtn.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        autoBtn.setTitleColor(#colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1), for: .normal)
        sizeSlider.value = 0.5
        mode = 1
    }
    
    func initSlider() {
        sizeSlider.maximumValue = 1
        sizeSlider.minimumValue = 0
        sizeSlider.value = 0.5
        sizeSlider.maximumTrackTintColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        sizeSlider.minimumTrackTintColor = #colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1)
        sizeSlider.addTarget(self, action: #selector(changeSize(sender:)), for: .valueChanged)
    }
    
    @objc func changeSize(sender: UISlider) {
        let sizeOpe = sender.value * 2.0
        if mode == 0 {
            sizeRatio = CGFloat(sizeOpe)
            drawAutoImage()
        } else {
            for imgView in manualStampViews {
                imgView.transform = CGAffineTransform(scaleX: CGFloat(sizeOpe), y: CGFloat(sizeOpe))
            }
        }
    }

    func drawAutoImage() {
        let editedImage: UIImage?
        UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        for rect in autoImageRect {
            print(rect)
            selectedHige.draw(in: CGRect(x: rect.origin.x - rect.width * sizeRatio / 2, y: rect.origin.y, width: rect.width * sizeRatio, height: rect.height * sizeRatio))
        }
        editedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.imageView.image = editedImage
    }
}

extension EditViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return higeImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height - 5, height: collectionView.frame.height - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "higeCell", for: indexPath) as! HigeCollectionViewCell
        cell.imageView.image = higeImages[indexPath.row]
        cell.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if mode == 0 {
            selectedHige = higeImages[indexPath.row]
            drawAutoImage()
        } else {
            let center = imageView.center
            let newHige = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            newHige.image = higeImages[indexPath.row]
            newHige.contentMode = .scaleAspectFill
            newHige.center = center
            newHige.isUserInteractionEnabled = true
            imageView.addSubview(newHige)
            manualStampViews.append(newHige)
        }
    }
    
}
