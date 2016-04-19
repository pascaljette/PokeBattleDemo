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
import UIKit

/// Delegate for the state machine.  It is a sum of all the states delegates.
protocol StateMachineDelegate: class
    , PlayerActionStateDelegate
    , FightStateDelegate
    , InitialDrawGameStateDelegate {
    
}

/// State machine used to determine at which part of the application's flow we currently are.
class StateMachine {
    
    //
    // MARK: Stored properties
    //

    /// Delegate for the state machine.
    weak var delegate: StateMachineDelegate?

    /// Current active state of the state machine.
    var currentState: GameState?

    
    //
    // MARK: Initialization
    //

    /// Parameterless initializer.
    /// At this point, the state machine is not really initialized until the start method is called.
    init() {
    
    }
}

extension StateMachine {
    
    //
    // MARK: Public methods
    //
    
    /// Proceed to next state and calls its visual setup function.
    func proceedToNextState() {
        
        currentState = currentState?.nextState
        currentState?.setupViewForState()
    }
    
    /// Start the state machine and initializes the state scheme as well as 
    /// assign the first state.  All states are also assigned their proper
    /// delegate.
    func start() {
        
        // Start the initial state.
        currentState = InitialDrawGameState()
        (currentState as? InitialDrawGameState)?.delegate = delegate
        
        var stateToAssign: GameState? = currentState

        // Each player gets x turns.  Assign the states here properly.
        for _ in 0 ..< GlobalConstants.NUMBER_OF_TURNS_PER_PLAYER {
            
            let player1State = PlayerActionState(playerId: .PLAYER_1)
            player1State.delegate = self.delegate
            stateToAssign?.nextState = player1State
            
            let player2State = PlayerActionState(playerId: .PLAYER_2)
            player2State.delegate = self.delegate
            player1State.nextState = player2State
            
            stateToAssign = player2State
        }
        
        // Last state is the fight state.
        let fightState = FightState()
        fightState.delegate = self.delegate
        stateToAssign?.nextState = fightState
        
        // Setup the view for the initial state after everything is setup.
        currentState?.setupViewForState()
    }
}
