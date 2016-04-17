// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import GearKit

protocol BattleScreenTileDelegate: class {
    
    func tileButtonPressed(sender: BattleScreenTile)
}

// TODO fix all these dispatch to UI thread, they are unacceptable.
class BattleScreenTile: UIView {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageButton: UIButton!
    
    @IBOutlet weak var typeImage1: UIImageView!
    
    @IBOutlet weak var typeImage2: UIImageView!
    
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    weak var delegate: BattleScreenTileDelegate?
    
    var loading: Bool = false {
        
        didSet {
         
            if loading {
                
                nameLabel.text = nil
                typeImage1.image = nil
                typeImage2.image = nil
                imageButton.setBackgroundImage(nil, forState: .Normal)
                activityIndicator.startAnimating()
            
            } else {
                
                activityIndicator.stopAnimating()
            }
        }
        
    }
    
    var pokemon: Pokemon? {
        
        // TODO this needs to be refactored and/or optimized to remove all the thread dispatching stuff
        didSet {
            
            guard let pokemonInstance = self.pokemon else {
                
                GKThread.dispatchOnUiThread {

                    self.nameLabel.text = nil
                    self.imageButton.setBackgroundImage(nil, forState: .Normal)
                }
                
                loading = false
                return
            }
            
            GKThread.dispatchOnUiThread {

                self.nameLabel.text = pokemonInstance.name.uppercaseString
                
                if let firstType = pokemonInstance.types.first {
                    
                    self.typeImage1.image = PokemonTypeMapping(rawValue: firstType.name)?.getImage()
                }
                
                
                if pokemonInstance.types.isInBounds(1) {
                    
                    self.typeImage2.image = PokemonTypeMapping(rawValue: pokemonInstance.types[1].name)?.getImage()
                }
            }

            guard let imageUrl = NSURL(string: pokemonInstance.spriteUrl) where !String.isNilOrEmpty(pokemonInstance.spriteUrl) else {
                
                GKThread.dispatchOnUiThread {

                    self.imageButton.setBackgroundImage(UIImage(named: "NoImageDefault.png"), forState: .Normal)
                    self.loading = false
                }
                
                return
            }
            
            let task = NSURLSession.sharedSession().dataTaskWithURL(imageUrl) {[weak self] (data, response, error) in
                
                guard let strongSelf = self else {
                    
                    return
                }
                
                GKThread.dispatchOnUiThread {
                    
                    strongSelf.loading = false
                }
                
                // TODO Error handling!
                guard error == nil else {
                    
                    print("Error retrieving image: \(imageUrl.absoluteString)")
                    return
                }
                
                if let dataInstance = data {
                    
                    let image = UIImage(data : dataInstance)
                    
                    GKThread.dispatchOnUiThread {
                        
                        strongSelf.imageButton.setBackgroundImage(image, forState: .Normal)
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
        
        activityIndicator.stopAnimating()
        
        self.addSubview(self.view)
        
        // Restore constraints when loaded in interface builder.
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterY , metrics: nil, views: ["view": self.view]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: NSLayoutFormatOptions.AlignAllCenterX , metrics: nil, views: ["view": self.view]))

    }
}

extension BattleScreenTile {
    
    @IBAction func imageButtonPressed(sender: AnyObject) {
        
        delegate?.tileButtonPressed(self)
    }
}
