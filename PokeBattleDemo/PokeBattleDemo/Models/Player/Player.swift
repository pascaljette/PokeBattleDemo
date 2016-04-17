//
//  Player.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

enum PlayerId {
    
    case PLAYER_1
    case PLAYER_2
}

class Player {
    
    var id: PlayerId
    
    var pokemonDraw: [Pokemon] = []
    
    init(id: PlayerId, pokemonDraw: [Pokemon]) {
        
        self.id = id
        self.pokemonDraw = pokemonDraw
    }
}
