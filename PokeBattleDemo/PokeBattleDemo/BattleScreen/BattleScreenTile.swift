//
//  BattleScreenTile.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import GearKit

class BattleScreenTile: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var view: UIView!
    
    var pokemon: Pokemon? {
        
        didSet {
            
            GKThread.dispatchOnUiThread { [weak self] in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                strongSelf.nameLabel.text = strongSelf.pokemon?.name
                
                guard let imageUrl = strongSelf.pokemon?.spriteUrl else {
                    
                    strongSelf.imageButton.setBackgroundImage(nil, forState: .Normal)
                    return
                }
                
                // TODO error checking!
                // There is a case where URLs will be empty.  Need to be considered.
                let url = NSURL(string: imageUrl)
                let data = NSData(contentsOfURL : url!)
                let image = UIImage(data : data!)

                strongSelf.imageButton.setBackgroundImage(image, forState: .Normal)
                
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        setupView()
    }
    
    private func setupView() {
        
        let className = String(self.dynamicType)
        self.view = NSBundle.mainBundle().loadNibNamed(className, owner: self, options: nil).first as! UIView
        
        self.addSubview(self.view)
        
        // Restore constraints when loaded in interface builder.
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["view": self.view]))

    }
}

extension BattleScreenTile {
    
    @IBAction func imageButtonPressed(sender: AnyObject) {
        
        print("image button pressed")
    }
}
