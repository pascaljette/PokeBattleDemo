//
//  PokemonType.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

class PokemonType : PokeApiModelBase {
    
    required init() {
        
    }
    
    var noDamageToTypes: [PokemonTypeIdentifier] = []
    var halfDamageToTypes: [PokemonTypeIdentifier] = []
    var doubleDamageToTypes: [PokemonTypeIdentifier] = []

    var typeIdentifier: PokemonTypeIdentifier = PokemonTypeIdentifier()
}
