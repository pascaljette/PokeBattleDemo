//
//  BattleResult.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/17/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation


class BattleResult {

    var player1Result: PlayerResult
    var player2Result: PlayerResult
    
    init(player1Result: PlayerResult, player2Result: PlayerResult) {

        self.player1Result = player1Result

        self.player2Result = player2Result
    }
    
    var winner: Player? {
        
        if player1Result.score > player2Result.score {
            
            return player1Result.player
        
        } else if player2Result.score > player1Result.score {
            
            return player2Result.player
        }
        
        // Return nil in case of a draw
        return nil
    }
}
