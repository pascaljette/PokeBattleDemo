//
//  GameState.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol GameState {
    
    var nextState: GameState? { get set }
    
    var actionButtonText: String { get }
    
    func actionButtonPressed()
    
    func setupViewForState()
}
