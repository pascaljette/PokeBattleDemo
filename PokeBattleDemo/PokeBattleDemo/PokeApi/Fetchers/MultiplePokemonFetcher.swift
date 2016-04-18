//
//  MultiplePokemonFetcher.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol MultiplePokemonFetcherDelegate: class {
    
    func didGetPokemonArray(success: Bool, result: [Pokemon]?, error: NSError?)
}

/// Only supports random fetching now.
class MultiplePokemonFetcher {
    
    //
    // MARK: Stored properties
    //
    
    weak var delegate: MultiplePokemonFetcherDelegate?
    
    private var pokemonFetchers: [RandomPokemonFetcher] = []
    private var count: Int
    
    private var pokemonArray: [Pokemon] = []
    private var success: Bool = true
    private var error: NSError?
    
    private let dispatchGroup = dispatch_group_create();
    
    //
    // MARK: Initialization
    //
    
    init(count: Int) {
        
        self.count = count
    }
}

extension MultiplePokemonFetcher {
    
    func fetch(allPokemonList: AllPokemonList) {
        
        for _ in 0..<count {
            
            let pokemonFetcher = RandomPokemonFetcher(allPokemonList: allPokemonList)
            pokemonFetcher.delegate = self
            pokemonFetchers.append(pokemonFetcher)
            
            dispatch_group_enter(dispatchGroup)
            
            pokemonFetcher.fetch()

        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.delegate?.didGetPokemonArray(strongSelf.success
                , result: strongSelf.pokemonArray
                , error: strongSelf.error)
        }
    }
}

extension MultiplePokemonFetcher : RandomPokemonFetcherDelegate {
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?) {
     
        defer {
            
            dispatch_group_leave(dispatchGroup)
        }

        guard let pokemonInstance = result where success == true else {
            
            self.success = false
            self.error = error
            
            return
        }
        
        self.pokemonArray.append(pokemonInstance)
    }
}
