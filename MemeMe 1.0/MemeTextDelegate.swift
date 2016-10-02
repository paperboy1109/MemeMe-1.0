//
//  MemeTextDelegate.swift
//  MemeMe 1.0
//
//  Created by Daniel J Janiak on 5/22/16.
//  Copyright © 2016 Daniel J Janiak. All rights reserved.
//

import Foundation
import UIKit

class MemeTextDelegate: NSObject, UITextFieldDelegate {
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        //If this is the first time entering text, clear the text field
        if let text = textField.text , text.isEmpty
        {
            textField.placeholder = ""
            textField.defaultTextAttributes = [
                NSStrokeColorAttributeName: UIColor.black,
                NSForegroundColorAttributeName: UIColor.white,
                NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
                NSStrokeWidthAttributeName: -5
                ] as [String : Any]
            textField.textAlignment = NSTextAlignment.center
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
                
    
}
