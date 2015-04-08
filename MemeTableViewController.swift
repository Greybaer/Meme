//
//  MemeTableViewController.swift
//  Meme
//
//  Created by Greybear on 3/30/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class MemeTableViewController: UIViewController, UITableViewDataSource{
    
    @IBOutlet weak var addMeme: UIBarButtonItem!
    @IBOutlet weak var memeTable: UITableView!
    //'Edit' button...
    @IBOutlet weak var memeEdit: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(animated: Bool) {
        //Reload the meme data
        memeTable.reloadData()
    }
    
    //Table view methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (UIApplication.sharedApplication().delegate as AppDelegate).memes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let memes = (UIApplication.sharedApplication().delegate as AppDelegate).memes
        let cell = tableView.dequeueReusableCellWithIdentifier("memeCell", forIndexPath: indexPath) as MemeTableViewCell
        //Grab the entry for each row
        let meme = memes[indexPath.row]

        // Configure the cell...
        cell.memeImage.image = meme.memedImage?
        cell.topText.text = meme.topText?
        cell.bottomText.text = meme.bottomText?
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath){
        //Show the selected memem in a Detail View
        let memes = (UIApplication.sharedApplication().delegate as AppDelegate).memes
        let meme = memes[indexPath.row]
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MemeDetailViewController") as MemeDetailViewController
        controller.meme = meme
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //Bonus - delete a meme
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        //Delete the selected entry
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.removeAtIndex(indexPath.row)
        //and reload the data
        memeTable.reloadData()
    }


    //Add a Meme from the action button in collection/table view
    @IBAction func newMeme(sender: UIBarButtonItem) {
        let controller =
        self.storyboard?.instantiateViewControllerWithIdentifier("memeEditor") as MemeEditorViewController
        self.navigationController?.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func deleteMeme(sender: UIBarButtonItem) {
        //We're editing, so stop
        if memeTable.editing{
            memeTable.setEditing(false, animated: true)
            sender.style = UIBarButtonItemStyle.Plain
            sender.title = "Edit"
        }
        //We're not, so start
        else{
            memeTable.setEditing(true, animated: true)
            sender.title = "Done"
            sender.style = UIBarButtonItemStyle.Done
        }
    }
    

}
