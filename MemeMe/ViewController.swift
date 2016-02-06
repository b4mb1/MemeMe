//
//  ViewController.swift
//  MemeMe
//
//  Created by Klaudyna Marciniak on 24.11.2015.
//  Copyright © 2015 Klaudyna Marciniak. All rights reserved.
//


//  temporary setting for iphone 6, app needs to be adapted to other devices

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var actionButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imagePickerView: UIImageView!
    //check if this is right
    var topTextField: UITextField!
    var bottomTextField: UITextField!
    @IBOutlet weak var topBar: UIToolbar!
    @IBOutlet weak var bottomBar: UIToolbar!
    
    
    //rozwazyc inne uzycie if let !!
    
    // TODO:
    // constraints
    // vertical spacing to margins after changing textfields
    // set capitalized string in ipads
    //there is a bug when clicking first bottom then top without returning from bottom
    // button to quit app
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionButton.enabled = false
        topTextField = UITextField(frame: CGRectMake(self.view.center.x - 125, 100, 250.0, 42))
        bottomTextField = UITextField(frame: CGRectMake(self.view.center.x - 125, 480, 250.0, 42))
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        customizeTextFields([topTextField, bottomTextField])
        
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
            return false
        }
        else {
            return true
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait, UIInterfaceOrientationMask.PortraitUpsideDown]
    }
    
    func customizeTextFields(arrayOfTextFields: [UITextField]) {
        
        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -3
        ]
        
        for textField in arrayOfTextFields {
            textField.delegate = self
            textField.defaultTextAttributes = memeTextAttributes
            textField.adjustsFontSizeToFitWidth = true
            textField.autocapitalizationType = UITextAutocapitalizationType.AllCharacters
            textField.minimumFontSize = 20
            textField.textAlignment = NSTextAlignment.Center
            self.view.addSubview(textField)
        }
    }

   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if imagePickerView.image != nil {
            actionButton.enabled = true
        }
        
        subscribeToKeyboardNotifications()
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:" , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"  , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder() {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func generateMemedImage() -> UIImage? {
        topBar.hidden = true
        bottomBar.hidden = true
        self.navigationController?.toolbarHidden = true
        if let frameForSnapshot = getThePositionOfImage(imagePickerView) {
            UIGraphicsBeginImageContextWithOptions(frameForSnapshot.size, false, 0)
            self.view.drawViewHierarchyInRect(CGRectMake(-frameForSnapshot.origin.x, -frameForSnapshot.origin.y, view.bounds.size.width,view.bounds.size.height), afterScreenUpdates: true)
            let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            topBar.hidden = false
            bottomBar.hidden = false
            return memedImage
        }
        return nil
    }
    
    
    func getThePositionOfImage(imageView: UIImageView) -> CGRect?{
        if let imageInImageView = imageView.image {
            let horizontalRatio = CGFloat(imageView.frame.size.width / imageInImageView.size.width)
            let verticalRatio = CGFloat(imageView.frame.size.height / imageInImageView.size.height)
            let ratio = (min(horizontalRatio, verticalRatio))
            let w = (imageInImageView.size.width) * ratio
            let h = (imageInImageView.size.height) * ratio
            let x = ((self.view.frame.size.width) - w)/2
            let y = ((self.view.frame.size.height) - h)/2
            return CGRectMake(x, y, w, h)
        }
        return nil
    }



    func save() -> meme? {
        if let memeImage = generateMemedImage() {
            let Meme = meme(topString: topTextField.text!, bottomString: bottomTextField.text!, pickedImage: imagePickerView.image!, memeImage: memeImage)
            UIImageWriteToSavedPhotosAlbum(memeImage, nil, nil, nil)
            return Meme
        }
        return nil
    }
    
    func setFontForAllTextFields() {
        if var topFont = topTextField.font?.pointSize, bottomFont = bottomTextField.font?.pointSize {
            let smallerFont = min(topFont, bottomFont)
            topFont = smallerFont
            bottomFont = smallerFont
        }
    }
    
    @IBAction func pickAPhoto(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func sharePhoto(sender: AnyObject) {
        if let image = generateMemedImage() {
            let nextViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
            nextViewController.completionWithItemsHandler = {
                activity, completed, items, error in
                if completed {
                    self.save()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
            self.presentViewController(nextViewController, animated: true, completion: nil)
        }
    }


    @IBAction func takeAPhoto(sender: AnyObject) {
        let nextViewController = UIImagePickerController()
        nextViewController.delegate = self
        nextViewController.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(nextViewController, animated: true, completion: nil)
        
        //picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
}

extension ViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickerView.image = image
            if let imageRect = getThePositionOfImage(imagePickerView) {
                topTextField.frame.size.width = imageRect.width
                topTextField.frame.origin = imageRect.origin
                bottomTextField.frame.size.width = imageRect.width
                bottomTextField.frame.origin.y = imageRect.height + imageRect.origin.y - 42
                bottomTextField.frame.origin.x = imageRect.origin.x
                
            }
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //setFontForAllTextFields()
        if textField.text?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) == "" {
            if textField.frame.origin.y < view.frame.height/2 {
                textField.text = "TOP"
            }
            else {
                textField.text = "BOTTOM"
            }
        }
    }
}