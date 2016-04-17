//
//  PlayerResult.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/17/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

class PlayerResult {
    
    var score: Double
    var player: Player
    
    init(player: Player, score: Double) {
        
        self.score = score
        self.player = player
    }
}
