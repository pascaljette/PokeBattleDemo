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

protocol StateMachineDelegate: class
    , PlayerActionStateDelegate
    , FightStateDelegate
    , InitialDrawGameStateDelegate {
    
}

class StateMachine {
    
    // Put this in a plist
    private let NUMBER_OF_TURNS_PER_PLAYER: Int = 2
    
    weak var delegate: StateMachineDelegate?
    
    init() {
    
    }
    
    func proceedToNextState() {
        
        currentState = currentState?.nextState
        currentState?.setupViewForState()
    }
    
    func start() {
        
        currentState = InitialDrawGameState()
        (currentState as? InitialDrawGameState)?.delegate = delegate
        
        var stateToAssign: GameState? = currentState
        
        
        for _ in 0 ..< NUMBER_OF_TURNS_PER_PLAYER {
            
            let player1State = PlayerActionState(playerId: .PLAYER_1)
            player1State.delegate = self.delegate
            stateToAssign?.nextState = player1State
            
            let player2State = PlayerActionState(playerId: .PLAYER_2)
            player2State.delegate = self.delegate
            player1State.nextState = player2State
            
            stateToAssign = player2State
        }
        
        let fightState = FightState()
        fightState.delegate = self.delegate
        stateToAssign?.nextState = fightState
        
        currentState?.setupViewForState()
    }
    
    var currentState: GameState?
}
