// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import UIKit

/// Mappings for pokemon types and their internal image file.
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
    
    /// Get the mapped image for the pokemon type.  Since all images are kept locally,
    /// we will force crash if an image is not properly retrieved.
    ///
    /// - returns: Generated image from the pokemon type.
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
