//
//  MemeDetailViewController.swift
//  Meme
//
//  Created by Greybear on 4/7/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class MemeDetailViewController: UIViewController {

   
    @IBOutlet weak var memeDetailView: UIImageView!
    
    //The meme we need to display
    var meme: Meme?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //The struct saves a completed image, so the implementation is trivial
        memeDetailView.image = meme?.memedImage
    }
}
