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
    
    var pokemonList: AllPokemonList
    var initialDrawPlayer1: [Pokemon]
    var initialDrawPlayer2: [Pokemon]
    
    
    //
    // MARK: Initialisation.
    //
    
    /// Initialise with a model.
    ///
    /// - parameter model: Model to use to initialise the view controller.
    init(pokemonList: AllPokemonList, initialDrawPlayer1: [Pokemon], initialDrawPlayer2: [Pokemon]) {
        
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
