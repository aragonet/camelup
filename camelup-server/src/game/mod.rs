pub mod pyramid;
pub mod race_circuit;
pub mod round_market;
use rand::distributions::{Alphanumeric, Distribution, Uniform};
use rand::{thread_rng, Rng};
use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Camel {
    id: u8,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct Player {
    pub id: String,
    pub points: u8,
}

impl Player {
    pub fn new() -> Player {
        let rand_string: String = thread_rng().sample_iter(&Alphanumeric).take(1).collect();
        return Player {
            id: rand_string,
            points: 0,
        };
    }
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
            players: vec![Player::new(), Player::new()],
            circuit: vec![vec![]; 17],
            dice_pool: pyramid::new_dice_pool(),
            round_cards: round_market::new_cards(),
            player_turn: 0,
            game_ended: false,
        };
        let mut rng = rand::thread_rng();
        let first_player = Uniform::from(0..game.players.len()).sample(&mut rng);
        game.player_turn = first_player + 1;
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

    pub fn is_player_turn(&self, player_id: u8) -> bool {
        return player_id == self.player_turn as u8;
    }

    pub fn on_round_ended(&mut self) {
        round_market::give_out_points(&self.round_cards, &mut self.players, &self.circuit);
        self.dice_pool = pyramid::new_dice_pool();
        self.round_cards = round_market::new_cards();
    }

    pub fn on_game_end(&mut self) {
        self.game_ended = true;
        round_market::give_out_points(&self.round_cards, &mut self.players, &self.circuit);
    }

    pub fn next_player(&mut self) {
        self.player_turn += 1;
        if self.player_turn >= self.players.len() as usize {
            self.player_turn = 1;
        }
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
