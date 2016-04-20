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

/// Delegate for the initial state.
protocol InitialDrawGameStateDelegate: class {
    
    /// Delegate must implement the action when the start button is pressed.
    func didPressStartButton()
    
    /// Delegate is responsible for setting the view when this state becomes active.
    func setupViewForInitialState()
}

/// Initial state for when the draw is complete and we're waiting for the player to start.
class InitialDrawGameState: GameState {
    
    //
    // MARK: Stored properties
    //
    
    /// Reference on the delegate.
    weak var delegate: InitialDrawGameStateDelegate?
    
    //
    // MARK: GameState implementation
    //
    
    /// Reference on the next state.
    var nextState: GameState?
    
    /// Text for the action button.
    var actionButtonText: String {
        return NSLocalizedString("START", comment: "Start State")
    }
    
    /// When the action button is pressed, defer to the delegate..
    func actionButtonPressed() {
        
        delegate?.didPressStartButton()
    }
    
    /// To setup the view corresponding to this state, defer to the delegate.
    func setupViewForState() {
        
        delegate?.setupViewForInitialState()
    }
}
