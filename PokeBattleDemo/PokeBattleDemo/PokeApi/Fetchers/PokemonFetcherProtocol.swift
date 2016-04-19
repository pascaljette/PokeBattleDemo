//
//  PokemonFetcherProtocol.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/19/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

/// Protocol for all API fetcher classes
protocol PokemonFetcherProtocol {
    
    /// Request type
    associatedtype RequestType : PokeApiRequestBase
    
    /// Response type
    associatedtype ResponseType : PokeApiResponseBase
    
    /// Connection type built upon request type and response type
    associatedtype ConnectionType = PokeApiConnection<RequestType, ResponseType>
}
