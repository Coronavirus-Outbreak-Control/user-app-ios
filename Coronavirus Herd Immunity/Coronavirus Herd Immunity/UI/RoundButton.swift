//
//  RoundButton.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 13/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override var isEnabled: Bool {
        didSet{
            if self.isEnabled {
                self.tintColor = UIColor.white
            }
            else{
                self.tintColor = UIColor.white
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 10{
        didSet{
        self.layer.cornerRadius = cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat = 1{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }

}
