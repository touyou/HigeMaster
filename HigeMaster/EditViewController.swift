//
//  EditViewController.swift
//  HigeMaster
//
//  Created by 藤井陽介 on 2016/09/23.
//  Copyright © 2016年 touyou. All rights reserved.
//

import UIKit
import ProjectOxfordFace

final class EditViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var manualBtn: UIButton!
    @IBOutlet weak var autoBtn: UIButton!
    
    var image: UIImage!
    var faces: [MPOFace]!
    var mode: Int!
    var higeImages: [UIImage]!

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
        
        setAutoMode()
        
        putStamp()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pushCancelBtn() {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func pushShareBtn() {
        
    }
    
    @IBAction func pushAutoBtn() {
        setAutoMode()
    }
    
    @IBAction func pushManualBtn() {
        setManualMode()
    }
    
    func putStamp() {
        if mode == 0 {
            
        } else {
            
        }
    }
    
    func setAutoMode() {
        manualBtn.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        manualBtn.setTitleColor(#colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1), for: .normal)
        autoBtn.backgroundColor = #colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1)
        autoBtn.setTitleColor(#colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1), for: .normal)
        mode = 0
    }
    
    func setManualMode() {
        manualBtn.backgroundColor = #colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1)
        manualBtn.setTitleColor(#colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1), for: .normal)
        autoBtn.backgroundColor = #colorLiteral(red: 0.9782002568, green: 0.9782230258, blue: 0.9782107472, alpha: 1)
        autoBtn.setTitleColor(#colorLiteral(red: 0.2926914692, green: 0.8806881309, blue: 0.5701341033, alpha: 1), for: .normal)
        mode = 1
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
    
}
