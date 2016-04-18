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

/// Delegate for the player action state.
protocol PlayerActionStateDelegate: class {
    
    /// Delegate must implement the action when the skip button is pressed.
    func didPressSkipButton()
    
    /// Delegate is responsible for setting the view when this state becomes active.
    func setupViewForPlayerActionState(playerId: PlayerId)
}

/// State for when the players can take action.  For now, the only actions they can take is to skip
/// their turn or change a pokemon.
class PlayerActionState: GameState {
    
    //
    // MARK: Stored properties
    //

    /// Player id for this state.
    var playerId: PlayerId
    
    /// Reference on the delegate.
    weak var delegate: PlayerActionStateDelegate?

    //
    // MARK: Initialization
    //

    /// Initialize with a given player id.  A player action state cannot exist
    /// without knowing which player is associated with it.
    ///
    /// - parameter playerId: Player ID to associate with this state.
    init(playerId: PlayerId) {
        
        self.playerId = playerId
    }
    
    //
    // MARK: GameState implementation
    //

    /// Reference on the next state.
    var nextState: GameState?
    
    /// Text for the action button.
    var actionButtonText: String {
        return "Select Pokemon or press here to skip"
    }
    
    /// When the action button is pressed, defer to the delegate..
    func actionButtonPressed() {
        
        delegate?.didPressSkipButton()
    }
    
    /// To setup the view corresponding to this state, defer to the delegate.
    func setupViewForState() {
        
        delegate?.setupViewForPlayerActionState(playerId)
    }
}
