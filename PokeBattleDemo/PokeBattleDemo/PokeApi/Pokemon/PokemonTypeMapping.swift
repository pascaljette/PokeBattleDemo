//
//  PokemonTypeMapping.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/15/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import UIKit

enum PokemonTypeMapping: String {
    
    // id = 1
    case NORMAL = "normal"

    // id = 2
    case FIGHTING = "fighting"

    // id = 3
    case FLYING = "flying"

    // id = 4
    case POISON = "poison"

    // id = 5
    case GROUND = "ground"

    // id = 6
    case ROCK = "rock"

    // id = 7
    case BUG = "bug"

    // id = 8
    case GHOST = "ghost"

    // id = 9
    case STEEL = "steel"

    // id = 10
    case FIRE = "fire"

    // id = 11
    case WATER = "water"

    // id = 12
    case GRASS = "grass"

    // id = 13
    case ELECTRIC = "electric"

    // id = 14
    case PSYCHIC = "psychic"

    // id = 15
    case ICE = "ice"

    // id = 16
    case DRAGON = "dragon"

    // id = 17
    case DARK = "dark"
    
    // id = 18
    case FAIRY = "fairy"
    

    func getImage() -> UIImage {
        
        switch self {
            
        case NORMAL:
            return UIImage(named: "normal.png")!
            
        case FIGHTING:
            return UIImage(named: "fighting.png")!

        case FLYING:
            return UIImage(named: "flying.png")!

        case POISON:
            return UIImage(named: "poison.png")!

        case GROUND:
            return UIImage(named: "ground.png")!

        case ROCK:
            return UIImage(named: "rock.png")!

        case BUG:
            return UIImage(named: "bug.png")!

        case GHOST:
            return UIImage(named: "ghost.png")!

        case STEEL:
            return UIImage(named: "steel.png")!

        case FIRE:
            return UIImage(named: "fire.png")!

        case WATER:
            return UIImage(named: "water.png")!

        case GRASS:
            return UIImage(named: "grass.png")!

        case ELECTRIC:
            return UIImage(named: "electric.png")!

        case PSYCHIC:
            return UIImage(named: "psychic.png")!

        case ICE:
            return UIImage(named: "ice.png")!

        case DRAGON:
            return UIImage(named: "dragon.png")!

        case DARK:
            return UIImage(named: "dark.png")!

        case FAIRY:
            return UIImage(named: "fairy.png")!
        }
    }
}
