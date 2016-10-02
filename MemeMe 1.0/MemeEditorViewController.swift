//
//  ViewController.swift
//  MemeMe 1.0
//
//  Created by Daniel J Janiak on 5/22/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import UIKit
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func >= <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l >= r
  default:
    return !(lhs < rhs)
  }
}


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var topMemeText: UITextField!
    @IBOutlet var bottomMemeText: UITextField!
    @IBOutlet var memeView: UIImageView!
    @IBOutlet var cameraBtn: UIBarButtonItem!
    @IBOutlet var shareBtn: UIBarButtonItem!
    @IBOutlet var topToolbar: UIToolbar!
    @IBOutlet var bottomToolbar: UIToolbar!
    @IBOutlet var albumButton: UIBarButtonItem!
    
    var initialVerticalPosForView: CGFloat!
    
    var memeTextDelegate = MemeTextDelegate()
    let pickerController = UIImagePickerController()
    
    struct Meme {
        var topMemeText: String?
        var bottomMemeText: String?
        var originalImg: UIImage?
        var memeImg: UIImage?
    }
    
    let memeTextAttributes = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -5
    ] as [String : Any]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialVerticalPosForView = self.view.frame.origin.y
        
        pickerController.delegate = self
        
        setupTextField(topMemeText)
        setupTextField(bottomMemeText)
        
        setPlaceholderText(topMemeText, initialText: "TOP")
        setPlaceholderText(bottomMemeText, initialText: "BOTTOM")
        
        shareBtn.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)

        subscribeToKeyboardNotifications()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    // Actions when toolbar buttons are tapped
    
    @IBAction func pickAlbumImage(_ sender: AnyObject) {
        
        pickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func pickCameraImg(_ sender: AnyObject) {
        
        pickerController.sourceType = UIImagePickerControllerSourceType.camera
        
        present(pickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func launchActivityView() {
        
        let newMeme = generateMemedImg()
        
        let controller = UIActivityViewController(activityItems: [newMeme], applicationActivities: nil)
        
        present(controller, animated: true, completion: nil)
        
        controller.completionWithItemsHandler = {
            (activityType, completed, returnedItems, activityError) in
            
            if activityError == nil {
                if completed {
                    self.save(newMeme)
                }
                controller.dismiss(animated: true, completion: nil)
            }
        }
        
        
    }
    
    // Actions for updating the image
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            memeView.image = pickedImage
            
            shareBtn.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelMeme() {
        
        memeView.image = nil
        setPlaceholderText(topMemeText, initialText: "TOP")
        setPlaceholderText(bottomMemeText, initialText: "BOTTOM")
        shareBtn.isEnabled = false
        
    }
    
    func setPlaceholderText(_ textField: UITextField, initialText: String) {
        
        textField.text = ""
        
        textField.attributedPlaceholder = NSAttributedString(string: initialText, attributes: memeTextAttributes)
        
        
    }
    
    func setupTextField(_ textField: UITextField) {
        
        textField.delegate = memeTextDelegate
        
        textField.defaultTextAttributes = memeTextAttributes
        
        textField.textAlignment = NSTextAlignment.center
        
    }
    
    // Actions for sharing the meme
    func save(_ newMeme: UIImage) {
        
        _ = Meme( topMemeText: topMemeText.text!, bottomMemeText: bottomMemeText.text!, originalImg: memeView.image, memeImg: newMeme)
    }
    
    func generateMemedImg() -> UIImage {
        
        // Hide the toolbars so that they are not in the meme
        topToolbar.isHidden = true
        bottomToolbar.isHidden = true
        // Also hide the toolbar buttons
        cameraBtn.tintColor = UIColor.clear
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        
        let memedImg: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // Show the toolbars
        topToolbar.isHidden = false
        bottomToolbar.isHidden = false
        
        return memedImg
    }
    
    
    // Don't let the keyboard obstruct the view
    
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if bottomMemeText.isFirstResponder {
            if self.view.frame.origin.y >= initialVerticalPosForView {
                self.view.frame.origin.y = -getKeyboardHeight(notification)
            }
            
        }
        
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if bottomMemeText.isFirstResponder {
            if self.view.frame.origin.y < initialVerticalPosForView {
                self.view.frame.origin.y = initialVerticalPosForView
            }
        }
        
    }

    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MemeEditorViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }

    
    // Hide the status bar so it doesn't interfere with the top bar buttons
    override var prefersStatusBarHidden : Bool {
        return true
    }

}

