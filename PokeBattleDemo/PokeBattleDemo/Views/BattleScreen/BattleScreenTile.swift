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

/// Delegate for a battle screen tile.
protocol BattleScreenTileDelegate: class {
    
    /// Forward the call when the tile is pressed.
    ///
    /// - parameter sender: The tile forwarding the call.
    func tileButtonPressed(sender: BattleScreenTile)
}

/// Represents a tile containing the pokemon image, its name and its image to
/// display in the main action view controller.
class BattleScreenTile: UIView {
    
    //
    // MARK: IBOutlets.
    //
    
    /// Pokemon name label
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Pokemon image (button so it is pressable)
    @IBOutlet weak var imageButton: UIButton!
    
    /// Pokemon first type image
    @IBOutlet weak var typeImage1: UIImageView!
    
    /// Pokemon second type image
    @IBOutlet weak var typeImage2: UIImageView!
    
    /// Main view used for auto-layout.
    @IBOutlet weak var view: UIView!
    
    /// Main view used for auto-layout.
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    //
    // MARK: Stored properties.
    //
    
    /// Delegate to forward calls.
    weak var delegate: BattleScreenTileDelegate?
    
    /// Whether the current is loading or not.  Updates UI as well so make sure to always set
    /// from the UI thread.
    var loading: Bool = false {
        
        didSet {
         
            if loading {
                
                nameLabel.hidden = true
                typeImage1.hidden = true
                typeImage2.hidden = true
                imageButton.setBackgroundImage(nil, forState: .Normal)
                activityIndicator.startAnimating()
            
            } else {
                
                nameLabel.hidden = false
                typeImage1.hidden = false
                typeImage2.hidden = false
                
                activityIndicator.stopAnimating()
            }
        }
        
    }
    
    /// Set the pokemon on the tile. Updates UI as well so make sure to always set
    /// from the UI thread.
    var pokemon: Pokemon? {
        
        // TODO this needs to be refactored and/or optimized to remove all the thread dispatching stuff
        didSet {
            
            guard let pokemonInstance = self.pokemon else {
                
                self.nameLabel.text = nil
                self.imageButton.setBackgroundImage(nil, forState: .Normal)
                
                loading = false
                return
            }
            
            self.nameLabel.text = pokemonInstance.name.uppercaseString
            
            if let firstType = pokemonInstance.types.first {
                
                self.typeImage1.image = PokemonTypeMapping(rawValue: firstType.name)?.getImage()
            }
            
            if pokemonInstance.types.isInBounds(1) {
                
                self.typeImage2.image = PokemonTypeMapping(rawValue: pokemonInstance.types[1].name)?.getImage()
            }

            guard let imageUrl = NSURL(string: pokemonInstance.spriteUrl) where !String.isNilOrEmpty(pokemonInstance.spriteUrl) else {
                
                self.imageButton.setBackgroundImage(UIImage(named: "NoImageDefault.png"), forState: .Normal)
                self.loading = false
                
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
    
    //
    // MARK: Initialization.
    //

    /// Required init for initializating from interface builder.
    ///
    /// - parameter aDecoder: Codex used to decode from the nib.
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)

        setupView()
    }
    
}

extension BattleScreenTile {
    
    //
    // MARK: Private utility functions.
    //
    
    /// Setup the view when loading.  This will apply auto-layout even when the nib is directly 
    /// ssetup as a child view in interface builder.
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
    
    //
    // MARK: IBActions
    //
    
    /// Triggered when the image button is pressed.
    ///
    /// - parameter sender: Reference on the image button triggering the event.
    @IBAction func imageButtonPressed(sender: AnyObject) {
        
        delegate?.tileButtonPressed(self)
    }
}
