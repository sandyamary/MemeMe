//
//  MemeEditorViewController.swift
//  MemeMe 1.0
//
//  Created by Udumala, Mary on 2/27/17.
//  Copyright © 2017 Udumala, Mary. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let topTextFieldDelegate = TextFieldDelegate()
    let bottomTextFieldDelegate = TextFieldDelegate()
    
    @IBOutlet var imagePickerView: UIImageView!
    
    
    @IBOutlet var addButton: UIBarButtonItem!

    
    @IBOutlet var cameraButton: UIBarButtonItem!
    
    @IBOutlet var topTextField: UITextField!

    @IBOutlet var bottomTextField: UITextField!
    
    @IBOutlet var memeToolBar: UIToolbar!
    
    @IBOutlet var topToolBar: UIToolbar!
    
    @IBOutlet var shareButton: UIBarButtonItem!
    
    let memeTextAttributes: [String: Any] = [NSStrokeColorAttributeName: UIColor.black, NSForegroundColorAttributeName: UIColor.white, NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!, NSStrokeWidthAttributeName: -3.0 ]
    
    func customizeTextField(textField: UITextField, defaultText: String) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName: -3
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customizeTextField(textField: topTextField, defaultText: "TOP")
        customizeTextField(textField: bottomTextField, defaultText: "BOTTOM")
        topTextField.delegate = topTextFieldDelegate
        bottomTextField.delegate = bottomTextFieldDelegate
        shareButton.isEnabled = false

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
        guard let button = sender as? UIBarButtonItem else {
            return
        }
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if button == self.addButton {
            pickerController.sourceType = .photoLibrary
        } else if button == self.cameraButton {
            pickerController.sourceType = .camera
        }
        present(pickerController, animated: true, completion: nil)
    
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
            shareButton.isEnabled = true            
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelMemeEditor(_ sender: Any) {
        imagePickerView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        shareButton.isEnabled = false
        dismiss(animated: true, completion: nil)
    }
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_notification:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unSubscribeToKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide , object: nil)
    }
    
    
    //Helper fuctions to subscribe to keyboardWillShow notifications
    func keyboardWillShow(_notification: Notification) {
        if bottomTextField.isEditing {
        view.frame.origin.y = -getKeyboardHeight(_notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    //Helper fuctions to subscribe to keyboardWillHide notifications
    func keyboardWillHide(_notification: Notification) {
        view.frame.origin.y = 0
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
            }
        }
        self.present(controller, animated: true, completion: nil)
        
    }
    
    
    //function to save the meme
    func save() {
        let _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imagePickerView.image!, memedImage: generatedMemedImage())
    }

}

