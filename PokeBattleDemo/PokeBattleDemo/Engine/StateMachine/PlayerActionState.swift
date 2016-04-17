//
//  PlayerActionState.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol PlayerActionStateDelegate: class {
    
    func didPressSkipButton()
    func setupViewForPlayerActionState(playerId: PlayerId)
}

class PlayerActionState: GameState {
    
    var playerId: PlayerId
    
    init(playerId: PlayerId) {
        
        self.playerId = playerId
    }
    
    weak var delegate: PlayerActionStateDelegate?
    
    var nextState: GameState?
    var actionButtonText: String {
        return "Select Pokemon or Skip"
    }
    
    // Do nothing here.
    func actionButtonPressed() {
        
        delegate?.didPressSkipButton()
    }
    
    func setupViewForState() {
        
        delegate?.setupViewForPlayerActionState(playerId)
    }
}
