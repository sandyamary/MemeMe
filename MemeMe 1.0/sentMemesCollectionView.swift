//
//  sentMemesCollectionView.swift
//  MemeMe 1.0
//
//  Created by Udumala, Mary on 3/7/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import Foundation
import UIKit

class sentMemesCollectionView: UICollectionViewController {
    
    let appDelegateObject = UIApplication.shared.delegate as! AppDelegate
    
    
    @IBOutlet var memeCollectionView: UICollectionView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.memeCollectionView.backgroundColor = UIColor.darkGray
        
        let space:CGFloat = 1.0
        let widthDimension = (view.frame.size.width - (3 * space)) / 3.0
        let heightDimension = (view.frame.size.height - (3 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: widthDimension, height: heightDimension)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.memeCollectionView.reloadData()
        
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegateObject.memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as! collectionViewCell        
        let memes = appDelegateObject.memes
        let sentMeme = memes[(indexPath as NSIndexPath).row]
        cell.sentMemeImage.image = sentMeme.memedImage
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailController = self.storyboard!.instantiateViewController(withIdentifier: "MemeDetailViewController") as! MemeDetailViewController
        detailController.meme = appDelegateObject.memes[(indexPath as NSIndexPath).row]
        self.navigationController!.pushViewController(detailController, animated: true)
    }
    
}
