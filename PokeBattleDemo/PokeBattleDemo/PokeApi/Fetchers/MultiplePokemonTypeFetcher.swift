//
//  MultiplePokemonFetcher.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol MultiplePokemonTypeFetcherDelegate: class {
    
    func didGetPokemonTypeArray(fetcher: MultiplePokemonTypeFetcher, success: Bool, result: [PokemonType]?, error: NSError?)
}

/// Only supports random fetching now.
class MultiplePokemonTypeFetcher {
    
    //
    // MARK: Stored properties
    //
    
    weak var delegate: MultiplePokemonTypeFetcherDelegate?
    
    private var pokemonTypeFetchers: [PokemonTypeFetcher] = []

    private let pokemonTypeIdentifiers: [PokemonTypeIdentifier]
    
    private var pokemonTypeArray: [PokemonType] = []
    
    private var success: Bool = true
    private var error: NSError?
    
    private let dispatchGroup = dispatch_group_create();
    
    //
    // MARK: Initialization
    //
    
    init(pokemonTypeIdentifiers: [PokemonTypeIdentifier]) {
        
        self.pokemonTypeIdentifiers = pokemonTypeIdentifiers
    }
}

extension MultiplePokemonTypeFetcher {
    
    func fetch() {
        
        for typeIdentifier in self.pokemonTypeIdentifiers {
            
            let typeFetcher = PokemonTypeFetcher(pokemonTypeIdentifier: typeIdentifier)
            typeFetcher.delegate = self
            pokemonTypeFetchers.append(typeFetcher)
            
            dispatch_group_enter(dispatchGroup)
            
            typeFetcher.fetch()
            
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.delegate?.didGetPokemonTypeArray(strongSelf
                , success: strongSelf.success
                , result: strongSelf.pokemonTypeArray
                , error: strongSelf.error)
        }
    }
}

extension MultiplePokemonTypeFetcher : PokemonTypeFetcherDelegate {
    
    func didGetPokemonType(fetcher: PokemonTypeFetcher, success: Bool, result: PokemonType?, error: NSError?) {
    
        defer {
            
            dispatch_group_leave(dispatchGroup)
            pokemonTypeFetchers = pokemonTypeFetchers.filter( { $0 !== fetcher} )
        }
        
        guard let pokemonTypeInstance = result where success == true else {
            
            self.success = false
            self.error = error
            
            return
        }
        
        self.pokemonTypeArray.append(pokemonTypeInstance)
    }
}
