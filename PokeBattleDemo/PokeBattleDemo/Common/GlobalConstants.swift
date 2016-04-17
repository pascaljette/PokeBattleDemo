//
//  File.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation


final class GlobalConstants {
    
    class var POKEAPI_BASE_URL: String {
        return "http://pokeapi.co"
    }
    
    class var NUMBER_OF_POKEMON_PER_PLAYER: Int {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("PokemonCountPerPlayer") as! Int
    }
}
