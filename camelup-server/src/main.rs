mod game;
use serde::{Deserialize, Serialize};
use std::sync::{Arc, Mutex};
use ws::{listen, CloseCode, Handler, Message, Result, Sender};

#[derive(Serialize, Deserialize, Debug)]
struct GameRequest {
    throw_dice: bool,
    player_id: String,
    get_camel_round_card: u8,
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
            Err(_) => {
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

        let player_id = match game_guard
            .players
            .iter()
            .position(|x| x.id == request.player_id)
        {
            Some(id) => (id + 1) as u8,
            None => {
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: game_guard.clone(),
                    })
                    .unwrap(),
                );
            }
        };

        if !game_guard.is_player_turn(player_id) {
            return self.out.send(
                serde_json::to_string(&GameResponse {
                    error_code: 1,
                    game: game_guard.clone(),
                })
                .unwrap(),
            );
        }

        if request.throw_dice {
            game_guard.players[(player_id - 1) as usize].points += 1;
            let dice = game::pyramid::throw_dice(&mut game_guard.dice_pool);
            game::race_circuit::move_camel(dice.camel_id, dice.number, &mut game_guard.circuit);
        } else if request.get_camel_round_card != 0 {
            if request.get_camel_round_card >= game_guard.camels.len() as u8 {
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: game_guard.clone(),
                    })
                    .unwrap(),
                );
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
    // on add player to game ensure id is not repeated
    let game = Arc::new(Mutex::new(game::Game::new()));

    listen("127.0.0.1:3000", |out| Server {
        out: out,
        game: game.clone(),
    })
    .unwrap();
}
