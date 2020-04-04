mod game;
mod util;
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex, MutexGuard};
use std::time::{SystemTime, UNIX_EPOCH};
use ws::{listen, CloseCode, Handler, Message, Result, Sender};

#[derive(Serialize, Deserialize, Debug)]
struct GameRequest {
    new: bool,
    new_player: String, // string is game_id
    throw_dice: bool,
    player_id: String,
    get_camel_round_card: u8,
}

#[derive(Serialize, Deserialize, Debug)]
struct GameResponse {
    error_code: u8,
    game: game::Game,
    player_id: String,
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
            Err(_) => {
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: game_guard.clone(),
                        player_id: String::from(""),
                    })
                    .unwrap(),
                );
            }
        };

        println!("GameRequest: {:?}", request);
        let mut player_id = request.player_id.clone();

        let mut response_code = 0;
        if request.new {
            let now = SystemTime::now();
            let timestamp = now.duration_since(UNIX_EPOCH).expect("TIME PROBLEM");
            let timestamp: String = String::from(timestamp.as_nanos().to_string());
            let game_id = timestamp + &util::random_string(16);
            // Create new game and return it
            let game = game::Game::new(game_id);
        // TODO append game to games map
        } else if request.new_player != "" {
            let player = game::Player::new();
        } else {
            response_code = game_step(&mut game_guard, &request);
        }
        return self.out.send(
            serde_json::to_string(&GameResponse {
                error_code: response_code,
                game: game_guard.clone(),
                player_id: player_id,
            })
            .unwrap(),
        );
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
    // TODO on add player to game ensure id is not repeated
    // TODO this should be a games map
    let game = Arc::new(Mutex::new(game::Game::new(String::from("asd"))));

    listen("127.0.0.1:3000", |out| Server {
        out: out,
        game: game.clone(),
    })
    .unwrap();
}

fn game_step(game_guard: &mut MutexGuard<game::Game>, request: &GameRequest) -> u8 {
    if game_guard.game_ended {
        return 1;
    }

    let player_id = match game_guard
        .players
        .iter()
        .position(|x| x.id == request.player_id)
    {
        Some(id) => (id + 1) as u8,
        None => {
            return 1;
        }
    };

    if !game_guard.is_player_turn(player_id) {
        return 1;
    }

    if request.throw_dice {
        game_guard.players[(player_id - 1) as usize].points += 1;
        let dice = game::pyramid::throw_dice(&mut game_guard.dice_pool);
        game::race_circuit::move_camel(dice.camel_id, dice.number, &mut game_guard.circuit);
    } else if request.get_camel_round_card != 0 {
        if request.get_camel_round_card >= game_guard.camels.len() as u8 {
            return 1;
        }

        game::round_market::get_card(
            player_id,
            request.get_camel_round_card,
            &mut game_guard.round_cards,
        );
    }

    if game::race_circuit::camel_won(&game_guard.circuit) {
        game_guard.on_game_end();
    } else {
        if game::pyramid::is_the_round_ended(&mut game_guard.dice_pool) {
            game_guard.on_round_ended();
        }

        game_guard.next_player();
    }

    return 0;
}
