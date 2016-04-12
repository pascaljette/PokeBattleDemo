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

    
    @IBOutlet weak var tile1: BattleScreenTile!
    
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
                GKThread.dispatchOnUiThread {
                    
                    if let _: PokemonList = response?.model {
                        
                        print("success")
                    }
                }
                
            case .ConnectionError:
                GKThread.dispatchOnUiThread {
                }

            case .UrlError:
                GKThread.dispatchOnUiThread {
                }
            }
            
        }
        
        call.execute()
    }

}
