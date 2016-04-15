//
//  BattleScreenViewController.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import GearKit

// TODO can be made more elegant
class ExecutingTasksCounter {
    
    private var queue = dispatch_queue_create("shuffleForTile.task.counter", DISPATCH_QUEUE_SERIAL)
    private (set) var value : Int = 0
    
    var zeroAction: (() -> Void)?
    var nonZeroAction: (() -> Void)?
    
    func increment () {
        dispatch_sync(queue) {
            self.value += 1
        }
    }
    
    func decrement () {
        
        dispatch_sync(queue) {
            self.value -= 1
            
            // sanity check
            self.value = max(0, self.value)
            
            if self.value > 0 {
                
                self.nonZeroAction?()
            }
            
            if self.value == 0 {
                
                self.zeroAction?()
            }
        }
    }

}

class BattleScreenViewController : GKViewControllerBase {
    
    typealias GetPokemonListConnection = PokeApiConnection<GetPokemonListRequest, GetPokemonListResponse>
    typealias GetPokemonConnection = PokeApiConnection<GetPokemonRequest, GetPokemonResponse>

    
    @IBOutlet weak var team1poke1: BattleScreenTile!
    
    @IBOutlet weak var team1poke2: BattleScreenTile!

    @IBOutlet weak var team1poke3: BattleScreenTile!

    @IBOutlet weak var team2poke1: BattleScreenTile!

    @IBOutlet weak var team2poke2: BattleScreenTile!

    @IBOutlet weak var team2poke3: BattleScreenTile!

    @IBOutlet weak var actionButton: UIButton!
    
    var pokemonList: PokemonList = PokemonList()
    
    var shuffleForTileCounter: ExecutingTasksCounter = ExecutingTasksCounter()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // TODO localize
        self.navigationItem.title = "Pokermon!"
        
        shuffleForTileCounter.nonZeroAction = {
            
            GKThread.dispatchOnUiThread {
                
                self.actionButton.enabled = false
            }
        }
        
        shuffleForTileCounter.zeroAction = {
            
            GKThread.dispatchOnUiThread {
                
                self.actionButton.enabled = true
            }
        }
    }
    
    
    @IBAction func fightButtonPressed(sender: AnyObject) {
        
        actionButton.enabled = false
        
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
        
        shuffleForTileCounter.increment()
        
        GKThread.dispatchOnUiThread {
            
            tile.setLoading()
        }
        
        // No guarantee that we don't have duplicates, but that's OK.
        let randomPokemonUrl = pokemonList.pokemonUrlStrings[Int(arc4random_uniform(UInt32(pokemonList.pokemonUrlStrings.count)))]
        
        let getPokemonRequest = GetPokemonRequest(fullUrl: randomPokemonUrl)
        
        let call: GetPokemonConnection = GetPokemonConnection()
        
        call.onCompletion = { (status, error, response) in
            
            self.shuffleForTileCounter.decrement()
            
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
