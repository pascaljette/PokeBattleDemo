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
        
        // TODO this needs to be refactored and/or optimized to remove all the thread dispatching stuff
        didSet {
            
            guard let pokemonInstance = self.pokemon else {
                
                GKThread.dispatchOnUiThread {

                    self.nameLabel.text = nil
                    self.imageButton.setBackgroundImage(nil, forState: .Normal)
                }
                
                return
            }
            
            GKThread.dispatchOnUiThread {

                self.nameLabel.text = pokemonInstance.name.uppercaseString
            }

            guard let imageUrl = NSURL(string: pokemonInstance.spriteUrl) where !String.isNilOrEmpty(pokemonInstance.spriteUrl) else {
                
                GKThread.dispatchOnUiThread {

                    self.imageButton.setBackgroundImage(UIImage(named: "NoImageDefault.png"), forState: .Normal)
                }
                
                return
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(imageUrl) {(data, response, error) in
                
                // TODO Error handling!
                guard error == nil else {
                    
                    print("Error retrieving image: \(imageUrl.absoluteString)")
                    return
                }
                
                if let dataInstance = data {
                    
                    let image = UIImage(data : dataInstance)
                    
                    GKThread.dispatchOnUiThread {
                        
                        self.imageButton.setBackgroundImage(image, forState: .Normal)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        setupView()
    }
    
    private func setupView() {
        
        let className = String(self.dynamicType)
        self.view = NSBundle.mainBundle().loadNibNamed(className, owner: self, options: nil).first as! UIView
        
        nameLabel.text = nil
        nameLabel.minimumScaleFactor = 8.0 / nameLabel.font.pointSize
        nameLabel.adjustsFontSizeToFitWidth = true
        
        imageButton.setBackgroundImage(nil, forState: .Normal)
        
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
