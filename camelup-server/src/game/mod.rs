pub mod pyramid;
pub mod race_circuit;
pub mod round_market;
use rand::distributions::{Distribution, Uniform};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Camel {
    id: u8,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Player {
    pub id: u8,
    pub points: u8,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Game {
    pub camels: Vec<Camel>,
    pub players: Vec<Player>,
    pub circuit: Vec<Vec<u8>>,
    pub dice_pool: Vec<u8>,
    pub round_cards: Vec<Vec<round_market::Card>>,
    pub player_turn: usize,
    pub game_ended: bool,
}

impl Game {
    pub fn new() -> Game {
        let mut game = Game {
            camels: vec![Camel { id: 1 }, Camel { id: 2 }, Camel { id: 3 }],
            players: vec![Player { id: 1, points: 0 }, Player { id: 2, points: 0 }],
            circuit: vec![vec![]; 17],
            dice_pool: pyramid::new_dice_pool(),
            round_cards: round_market::new_cards(),
            player_turn: 0,
            game_ended: false,
        };

        let mut rng = rand::thread_rng();
        let first_player = Uniform::from(0..game.players.len()).sample(&mut rng);
        game.player_turn = first_player;

        validate_dice_and_camels(&pyramid::new_dice_pool(), &game.camels);
        validate_round_cards_and_camels(&round_market::new_cards(), &game.camels);

        for i in 0..game.camels.len() {
            let dice = pyramid::throw_dice(&mut game.dice_pool);
            let box_index = (dice.number - 1) as usize;
            game.circuit[box_index].push(game.camels[i].id);
        }

        game.dice_pool = pyramid::new_dice_pool();
        return game;
    }

    pub fn is_player_turn(player_id: u8, game: &Game) -> bool {
        return player_id == game.player_turn as u8;
    }
}

fn validate_dice_and_camels(dices: &Vec<u8>, camels: &Vec<Camel>) {
    if camels.len() != dices.len() {
        panic!("Camels and dices do not match");
    }
    for c in camels {
        if !dices.contains(&c.id) {
            panic!("Camel {} has no relative dice", c.id);
        }
    }
}

fn validate_round_cards_and_camels(cards: &Vec<Vec<round_market::Card>>, camels: &Vec<Camel>) {
    if cards.len() != camels.len() {
        panic!("Camels and round cards do not match")
    }
}
