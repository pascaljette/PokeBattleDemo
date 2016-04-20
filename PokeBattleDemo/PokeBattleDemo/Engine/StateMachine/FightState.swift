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

/// Delegate for the fight state.
protocol FightStateDelegate: class {
    
    /// Delegate must implement the action when the fight button is pressed.
    func didPressFightButton()
    
    /// Delegate is responsible for setting the view when this state becomes active.
    func setupViewForFightState()
}

/// Fight state.  This occurs after all pokemon have been drawn and we are ready to
/// call the battle engine to calculate the fight result.
class FightState: GameState {
    
    //
    // MARK: Stored properties
    //
    
    /// Reference on the delegate.
    weak var delegate: FightStateDelegate?
    
    //
    // MARK: GameState implementation
    //
    
    /// Reference on the next state.
    var nextState: GameState?
    
    /// Text for the action button.
    var actionButtonText: String {
        return NSLocalizedString("FIGHT_NOW", comment: "Fight State")
    }
    
    /// When the action button is pressed, defer to the delegate..
    func actionButtonPressed() {
        
        delegate?.didPressFightButton()
    }
    
    /// To setup the view corresponding to this state, defer to the delegate.
    func setupViewForState() {
        
        delegate?.setupViewForFightState()
    }
}
