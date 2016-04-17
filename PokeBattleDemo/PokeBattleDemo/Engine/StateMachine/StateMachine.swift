//
//  StateMachine.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

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
