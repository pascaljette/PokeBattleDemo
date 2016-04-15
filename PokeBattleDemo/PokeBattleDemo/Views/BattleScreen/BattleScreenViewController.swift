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

    @IBOutlet weak var actionButton: UIButton!
    
    var pokemonList: PokemonList
    var initialDrawPlayer1: [Pokemon]
    var initialDrawPlayer2: [Pokemon]
    
    
    //
    // MARK: Initialisation.
    //
    
    /// Initialise with a model.
    ///
    /// - parameter model: Model to use to initialise the view controller.
    init(pokemonList: PokemonList, initialDrawPlayer1: [Pokemon], initialDrawPlayer2: [Pokemon]) {
        
        self.pokemonList = pokemonList
        self.initialDrawPlayer1 = initialDrawPlayer1
        self.initialDrawPlayer2 = initialDrawPlayer2
        
        super.init(nibName: "BattleScreenViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported (no storyboard support)")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                        
        // TODO localize
        self.navigationItem.title = "Battle!"
        
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        team1poke1.pokemon = initialDrawPlayer1[0]
        team1poke2.pokemon = initialDrawPlayer1[1]
        team1poke3.pokemon = initialDrawPlayer1[2]

        team2poke1.pokemon = initialDrawPlayer2[0]
        team2poke2.pokemon = initialDrawPlayer2[1]
        team2poke3.pokemon = initialDrawPlayer2[2]
    }
    
    
    @IBAction func fightButtonPressed(sender: AnyObject) {
        
    }

    private func shuffleForTile(tile: BattleScreenTile) {
        
    }
}
