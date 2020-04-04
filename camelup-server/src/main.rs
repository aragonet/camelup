mod game;
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};
use ws::{listen, CloseCode, Handler, Message, Result, Sender};

#[derive(Serialize, Deserialize, Debug)]
struct GameRequest {
    throw_dice: bool,
    player_id: usize,
}

#[derive(Serialize, Deserialize, Debug)]
struct GameResponse {
    error_code: u8,
    game: game::Game,
}

struct Server {
    out: Sender,
    game: Arc<Mutex<game::Game>>,
}
impl Handler for Server {
    fn on_message(&mut self, msg: Message) -> Result<()> {
        let mut game_guard = self.game.lock().unwrap();
        let body = msg.into_text()?;
        let request: GameRequest = match serde_json::from_str(&body) {
            Ok(v) => v,
            Err(e) => {
                println!("{}", e);
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: game_guard.clone(),
                    })
                    .unwrap(),
                );
            }
        };
        println!("GameRequest: {:?}", request);
        if game_guard.game_ended {
            let serialized = serde_json::to_string(&GameResponse {
                error_code: 0,
                game: game_guard.clone(),
            })
            .unwrap();
            return self.out.send(serialized);
        }
        // println!("Main {:?}", self.game);
        if request.throw_dice {
            println!("{:?}", game_guard.dice_pool);
            let dice = game::pyramid::throw_dice(&mut game_guard.dice_pool);
            println!("{:?}", game_guard.dice_pool);
            game::race_circuit::move_camel(dice.camel_id, dice.number, &mut game_guard.circuit);
            game_guard.players[request.player_id].points += 1;
        }

        if game::pyramid::is_the_round_ended(&mut game_guard.dice_pool) {
            // TODO maybe should just use mutable cause clone slows down. Further reaserch needed.
            let round_cards = game_guard.round_cards.clone();
            let circuit = game_guard.circuit.clone();
            game::round_market::give_out_points(&round_cards, &mut game_guard.players, &circuit);
            // TODO restore betting cards
            game_guard.dice_pool = game::pyramid::new_dice_pool();
        }

        if game::race_circuit::camel_won(&game_guard.circuit) {
            game_guard.game_ended = true;
        }

        let serialized = serde_json::to_string(&GameResponse {
            error_code: 0,
            game: game_guard.clone(),
        })
        .unwrap();
        return self.out.send(serialized);
    }

    fn on_close(&mut self, code: CloseCode, reason: &str) {
        match code {
            CloseCode::Normal => println!("The client is done with the connection."),
            CloseCode::Away => println!("The client is leaving the site."),
            _ => println!("The client encountered an error: {}", reason),
        }
    }
}

fn main() {
    let game = Arc::new(Mutex::new(game::Game::new()));

    //println!("{}", Game::is_player_turn(0, &game));
    // Option 1. Throw dice.
    // let dice = pyramid::throw_dice(&mut game.dice_pool);
    // race_circuit::move_camel(dice.camel_id, dice.number, &mut game.circuit);
    // game.players[0].points += 1;
    // Option 2. Buy card.
    //round_market::get_card(1, 3, &mut round_cards);

    // if pyramid::is_the_round_ended(&mut dicePool) {
    // TODO withdraw points
    // round_market::give_out_points(&round_cards, &mut players, &circuit);
    // TODO restore betting cards
    // dicePool = pyramid::new_dice_pool();
    // }
    //    race_circuit::move_camel(0, 1, &mut circuit);

    //println!("{:?}", game);

    listen("127.0.0.1:3000", |out| Server {
        out: out,
        game: game.clone(),
    })
    .unwrap();
}
