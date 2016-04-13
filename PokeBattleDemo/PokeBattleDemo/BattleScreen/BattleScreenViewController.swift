//
//  BattleScreenViewController.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import GearKit

class BattleScreenViewController : GKViewControllerBase {
    
    typealias GetPokemonListConnection = PokeApiConnection<GetPokemonListRequest, GetPokemonListResponse>
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>

    
    @IBOutlet weak var team1poke1: BattleScreenTile!
    
    @IBOutlet weak var team1poke2: BattleScreenTile!

    @IBOutlet weak var team1poke3: BattleScreenTile!

    @IBOutlet weak var team2poke1: BattleScreenTile!

    @IBOutlet weak var team2poke2: BattleScreenTile!

    @IBOutlet weak var team2poke3: BattleScreenTile!

    
    var pokemonList: PokemonList = PokemonList()
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TODO localize
        self.navigationItem.title = "Pokermon!"        
    }
    
    
    @IBAction func fightButtonPressed(sender: AnyObject) {
        
        let call: GetPokemonListConnection = GetPokemonListConnection()
        
        call.onCompletion = { (status, error, response) in
            
            switch status {
                
            case .Success:
                print("success")
                
                GKThread.dispatchOnUiThread { [weak self] in
                    
                    guard let strongSelf = self else {
                        
                        return
                    }
                    
                    strongSelf.pokemonList = response?.model ?? PokemonList()
                    strongSelf.initialShuffle()
                }
                
                // TODO display error dialog
            case .ConnectionError:
                GKThread.dispatchOnUiThread {
                }

                // TODO display error dialog
            case .UrlError:
                GKThread.dispatchOnUiThread {
                }
            }
            
        }
        
        call.execute()
    }

    /// Pick 3 pokemon for each side.
    private func initialShuffle() {
        
        shuffleForTile(team1poke1)
        shuffleForTile(team1poke2)
        shuffleForTile(team1poke3)

        shuffleForTile(team2poke1)
        shuffleForTile(team2poke2)
        shuffleForTile(team2poke3)
    }
    
    private func shuffleForTile(tile: BattleScreenTile) {
        
        // No guarantee that we don't have duplicates, but that's OK.
        let randomPokemonUrl = pokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(pokemonList.pokemonUrlStrings.count)))]
        
        let getPokemonRequest = GetPokemonRequest(fullUrl: randomPokemonUrl)
        
        let call: GetPokemonConnection = GetPokemonConnection()
        
        call.onCompletion = { (status, error, response) in
            
            switch status {
                
            case .Success:
                print("success")
                
                GKThread.dispatchOnUiThread {
                    
                    tile.pokemon = response?.model
                }
                
            // TODO display error dialog
            case .ConnectionError:
                GKThread.dispatchOnUiThread {
                }
                
            // TODO display error dialog
            case .UrlError:
                GKThread.dispatchOnUiThread {
                }
            }
            
        }
        
        call.execute(getPokemonRequest)
    }
}
