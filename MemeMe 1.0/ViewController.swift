//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Udumala, Mary on 2/27/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let topTextFieldDelegate = TopTextFieldDelegate()
    let bottomTextFieldDelegate = BottomTextFieldDelegate()
    
    @IBOutlet var imagePickerView: UIImageView!
    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var topTextField: UITextField!

    @IBOutlet var bottomTextField: UITextField!
    
    @IBOutlet var memeToolBar: UIToolbar!
    
    @IBOutlet var topToolBar: UIToolbar!
    
    let memeTextAttributes: [String: Any] = [NSStrokeColorAttributeName: UIColor.black, NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName: -3.0 ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting default text for text fields
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        
        // Aligning text to be center
        topTextField.textAlignment = NSTextAlignment.center
        bottomTextField.textAlignment = .center
        
        // Setting additional attributes to text fields
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        // Incorporating delegates for the text fields
        topTextField.delegate = topTextFieldDelegate
        bottomTextField.delegate = bottomTextFieldDelegate
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unSubscribeToKeyboardNotifications()
    }
    
    @IBAction func pickAnImage(_ sender: Any) {
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("image picker")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("image picker cancelled")
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelMemeEditor(_ sender: Any) {
        print("meme editor cancelled")
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unSubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow , object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    
    //Helper fuctions to subscribe to keyboardWillShow notifications
    func keyboardWillShow(_notification: Notification) {
        view.frame.origin.y -= getKeyboardHeight(_notification)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //Helper fuctions to subscribe to keyboardWillHide notifications
    func keyboardWillHide(_notification: Notification) {
        view.frame.origin.y += getKeyboardHeight(_notification)
    }
    
    func generatedMemedImage() -> UIImage {
        
        //hide toolbar and navbar
        
        self.memeToolBar.isHidden = true
        self.topToolBar.isHidden = true
        
        //grab the memed image only
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //unhide the navbar and toolbar
        self.memeToolBar.isHidden = false
        self.topToolBar.isHidden = false
        
        return memedImage
    }
    
    
    @IBAction func shareAction(_ sender: Any) {
        
        let image = generatedMemedImage()
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        controller.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) -> Void in
            if completed == true {
                self.save()
                print("Saved")
            }
        }
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
    //function to save the meme
    func save() {
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generatedMemedImage())
    }

}

