//
//  FightState.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol FightStateDelegate: class {
    
    func didPressFightButton()
    func setupViewForFightState()
}

class FightState: GameState {
    
    weak var delegate: FightStateDelegate?
    
    var nextState: GameState?
    
    var actionButtonText: String {
        return "FIGHT !"
    }
    
    // Do nothing here.
    func actionButtonPressed() {
        
        delegate?.didPressFightButton()
    }
    
    func setupViewForState() {
        
        delegate?.setupViewForFightState()
    }
}
