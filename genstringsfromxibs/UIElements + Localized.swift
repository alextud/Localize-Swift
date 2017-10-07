//
//  UIElements + Localized.swift
//  genstringsfromxibs
//
//  Created by Efraim Budusan on 5/29/17.
//  Copyright © 2017 Tapptitude. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    var localizedText: String {
        set (key) {
            if key != "" {
                text = key.localized
            } else {
                text = text?.localized
            }
        }
        get {
            return text!
        }
    }
}

extension UIButton {
    
    var localizedText: String {
        set (key) {
            if key != "" {
                self.setTitle(key.localized, for: .normal)
            } else {
                self.setTitle(titleLabel?.text?.localized, for: .normal)
            }
        }
        get {
            return (titleLabel?.text)!
        }
    }
    
}

extension UITabBarItem {
    var localizedText: String {
        set (key) {
            if key != "" {
                title = key.localized
            } else {
                title = title?.localized
            }
        }
        get {
            return title!
        }
    }
}


extension UINavigationItem {
    var localizedText: String {
        set (key) {
            if key != "" {
                title = key.localized
            } else {
                title = title?.localized
            }
        }
        get {
            return title!
        }
    }
}

extension UIBarButtonItem {
    var localizedText: String {
        set (key) {
            if key != "" {
                title = key.localized
            } else {
                title = title?.localized
            }
        }
        get {
            return title!
        }
    }
}

extension UITextField {
    var localizedText: String {
        set (key) {
            if key != "" {
                placeholder = key.localized
            } else {
                placeholder = placeholder?.localized
            }
        }
        get {
            return placeholder ?? ""
        }
    }
}

extension UITextView {
    var localizedText: String {
        set (key) {
            if key != "" {
                text = key.localized
            } else {
                text = text?.localized
            }
        }
        get {
            return text!
        }
    }
}
