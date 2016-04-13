//
//  Pokemon.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

// TODO
// For some obscure reason, this crashes if made as a struct.
class Pokemon : PokeApiModelBase {
    
    var name: String = ""
    var spriteUrl: String = ""
    
    required init() {
        
    }
    
    init(name: String, spriteUrl: String) {
        
        self.name = name
        self.spriteUrl = spriteUrl
    }
}
