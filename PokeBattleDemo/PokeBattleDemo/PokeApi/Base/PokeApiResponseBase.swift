//
//  PokeApiResponseBase.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import SwiftyJSON

protocol PokeApiResponseBase {
    
    associatedtype ModelType: PokeApiModelBase
    
    init(json: JSON)
    
    // enforce the fact that every response must be associated with a model
    var model: ModelType { get set }
}
