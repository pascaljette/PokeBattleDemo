//
//  InitialDrawGameState.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol InitialDrawGameStateDelegate: class {
    
    func didPressStartButton()
    func setupViewForInitialState()
}


class InitialDrawGameState: GameState {
    
    weak var delegate: InitialDrawGameStateDelegate?
    
    var nextState: GameState?
    
    var actionButtonText: String {
        return "Start"
    }
    
    // Do nothing here.
    func actionButtonPressed() {
        
        delegate?.didPressStartButton()
    }
    
    func setupViewForState() {
        
        delegate?.setupViewForInitialState()
    }
}
