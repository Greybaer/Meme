//
//  MemeEditorViewController.swift
//  Meme
//
//  Created by Greybear on 3/25/15.
//  Copyright (c) 2015 Infinite Loop, LLC. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UITextFieldDelegate{

    
    //Outlets for the editor
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!

  
    //Keyboard flag to make sure we don't overextend the keyboard slide
    var kbUp: Bool! = false

    //The text attributes to give us black outline/white fill text
    let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -5.0
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the view's display correctly
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        //Is there a cammera on this device? Enable/disable button depending
        cameraButton.enabled=UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        //Text attributes
        //Set the font, color and outline
        topText.defaultTextAttributes=memeTextAttributes
        bottomText.defaultTextAttributes=memeTextAttributes
        //Center the text in the box
        topText.textAlignment=NSTextAlignment.Center
        bottomText.textAlignment=NSTextAlignment.Center
    
        
        //Subscribe to keyboad notification events so we know when to shift the display
        //The lesson encapsulates this in a function, but that seems silly. So sue me.
        //KB Show Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //KB Hide Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillDisappear:", name: UIKeyboardWillHideNotification,
            object: nil)
        //Not sure this is the way to go, but since I'm getting a tab bar in the editor, let's hide it.
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove us from keyboard notifications
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillShow:", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "keyboardWillDisappear:", object: nil)
    }
   
    //App Action methods
    //The user wants to select an image from the stored album
    @IBAction func imageFromAlbum(sender: UIBarButtonItem) {
        let pickController = UIImagePickerController()
        //println("Album button pressed")
        //println("Frame Y Origin pre-picture: \(self.view.frame.origin.y)")
        pickController.delegate = self
        pickController.sourceType=UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(pickController, animated: true, completion: nil)
    }
    
    //image from camera, if enabled
    @IBAction func imageFromCamera(sender: UIBarButtonItem){
        //The button works when enabled and causes the appropriate crash when it finds no
        //camera in the simulator... =\
        //println("Camera button pressed")
        let pickController = UIImagePickerController()
        pickController.delegate = self
        pickController.sourceType=UIImagePickerControllerSourceType.Camera
        self.presentViewController(pickController, animated: true, completion: nil)
    }
    
    //Meme capture methods
    //Combine the text fields, picture and the meme into a single meme object
    //NOTE - This will be re-wired to the Activity View for sharing
    func saveMeme(memedImage: UIImage!) {
        var newmeme = Meme(topText: topText.text, bottomText: bottomText.text, image: imageView.image, memedImage: memedImage)
        //Now it has to be referenced properly because the struct is now in AppDelegate
        (UIApplication.sharedApplication().delegate as AppDelegate).memes.append(newmeme)
        //println("Number of memes from saveMeme: \((UIApplication.sharedApplication().delegate as AppDelegate).memes.count)")
        
    }
    
    //This will be the new sharing function
    @IBAction func shareMeme(sender: UIBarButtonItem) {

        
        let memedImage: UIImage = generateMeme()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        activityController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed{
                self.saveMeme(memedImage)
                self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
            }
            //Here's where the Sent Memes Views will appear
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        self.presentViewController(activityController, animated: true, completion: nil)
       
    }
    
    //User cancelled the editor
    @IBAction func cancelEditor(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    //The actual combine funtion
   func generateMeme() -> UIImage {
    
        var memedImage: UIImage?
    
        //Hide the tool and nav bar
        self.topBar.hidden = true
        self.bottomBar.hidden = true
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        //Render the view to a single image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //Show tool and nav bar
        self.topBar.hidden = false
        self.bottomBar.hidden = false
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        return memedImage!
    }
    
    
    //imagePickerController methods
    
    //We got an image, so show it
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        self.imageView.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        //println("Frame Y Origin post-picture: \(self.view.frame.origin.y)")
        }
    
    //Keyboard methods

    //Slide the picture up to show bottom text when the keyboard slides in
    func keyboardWillShow(notification: NSNotification){
        //Getting multiple notifications, so we'll add a test to make sure we only respond to the first one
        if bottomText.editing && !kbUp{
        self.view.frame.origin.y -= getKeyboardHeight(notification)
        //Set the flag to block additional notifications for this session
        kbUp = true
        //println("Sliding Frame up: \(self.view.frame.origin.y)")
        }
    }

    //...and slide it back down when the user is done
    func keyboardWillDisappear(notification: NSNotification){
        if bottomText.editing{
        //just reset the origin to zero since we're getting multiple notifications
        self.view.frame.origin.y = 0
        //reset the flag
        kbUp = false
        //self.view.frame.origin.y += getKeyboardHeight(notification)
        //println("Sliding Frame down: \(self.view.frame.origin.y)")

        }
    }
    
    //The function that figures out the keyboard size
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo=notification.userInfo
        let keyboardSize=userInfo![UIKeyboardFrameEndUserInfoKey] as NSValue
        //println("Keyboard Height: \(keyboardSize.CGRectValue().height)")
        return keyboardSize.CGRectValue().height
    }

    //The user hit return, so stop editing and disregard the return key
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}


