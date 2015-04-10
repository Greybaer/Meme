//
//  MemeCollectionViewController.swift
//  Meme
//
//  Created by Greybear on 3/31/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import Foundation
import UIKit

class MemeCollectionViewController: UIViewController, UICollectionViewDataSource {
    
    //User action buttons
    @IBOutlet weak var memeCollection: UICollectionView!
    @IBOutlet weak var addMeme: UIBarButtonItem!
    
    //'Edit' the meme
    @IBOutlet weak var memeEdit: UIBarButtonItem!
   
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        //Are the memes emnpty? If so, pop up the editor. This should create the initial app functionality required by the spec. 
        //This will only happen on the initial load, as monitored by a global var

        if (UIApplication.sharedApplication().delegate as AppDelegate).memes.count == 0 {
            //Pop up the editor
            let controller =
            self.storyboard?.instantiateViewControllerWithIdentifier("memeEditor") as MemeEditorViewController
            self.navigationController?.presentViewController(controller, animated: true, completion: nil)
        }
        //println("Number of memes from ViewDidAppear: \((UIApplication.sharedApplication().delegate as AppDelegate).memes.count)")
        
        //Reload the data
        memeCollection.reloadData()
    }
    
    //Collection View methods
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let memes = (UIApplication.sharedApplication().delegate as AppDelegate).memes
        let meme = memes[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionViewCell", forIndexPath: indexPath) as MemeCollectionViewCell
        cell.memedImage.image = meme.memedImage
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (UIApplication.sharedApplication().delegate as AppDelegate).memes.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath:NSIndexPath){
        //With the edit function enabled, we hijack the selection event to determine whether
        //to show the Detail View or offer to delete a meme
        let memes = (UIApplication.sharedApplication().delegate as AppDelegate).memes
        let meme = memes[indexPath.row]
        
        //We're not editing, so show the detail view
        if !self.editing{
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        controller.meme = meme
        self.navigationController?.pushViewController(controller, animated: true)
        }
        else{//We're editing so show a confirmation dialog and delete this meme if confirmed
             //We need to do this because the CollectionView doesn't have a UI method to handle this like TableView does...
            
            //Create an alert
            var confirm = UIAlertController(title: "Delete Meme?", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
            //Cancel button just closes the dialog
            confirm.addAction(UIAlertAction(title: "Cancel",style: UIAlertActionStyle.Cancel, handler: nil))
            //Delete button does the dirty work
            confirm.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.Default, handler:
                { action in
                    //Delete the selected entry
                    (UIApplication.sharedApplication().delegate as AppDelegate).memes.removeAtIndex(indexPath.row)
                    //and reload the data
                    self.memeCollection.reloadData()
                }))
            self.presentViewController(confirm, animated: true, completion: nil)
        }
    }
    
    //Add a new meme from the action button on the table or collection view
    @IBAction func newMeme(sender: UIBarButtonItem) {
        let controller =
        self.storyboard?.instantiateViewControllerWithIdentifier("memeEditor") as MemeEditorViewController
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    //The monkey flips the switch, and we're doing this manually with collection views
    @IBAction func deleteMeme(sender: UIBarButtonItem) {
        //We're editing, so stop
        if self.editing{
            sender.style = UIBarButtonItemStyle.Plain
            sender.title = "Edit"
            self.editing = false
        }
            //We're not, so start
        else{
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
            self.editing = true
        }
    }
}//class
