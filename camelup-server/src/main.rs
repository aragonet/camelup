mod game;
mod util;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};
use ws::{listen, CloseCode, Handler, Message, Result, Sender};

#[derive(Serialize, Deserialize, Debug)]
struct GameRequest {
    #[serde(default)]
    game_id: String,
    #[serde(default)]
    new_game: bool,
    #[serde(default)]
    new_player: bool,
    #[serde(default)]
    start_game: bool,
    #[serde(default)]
    throw_dice: bool,
    #[serde(default)]
    player_id: String,
    #[serde(default)]
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
    games: Arc<Mutex<HashMap<String, game::Game>>>,
}
impl Handler for Server {
    fn on_message(&mut self, msg: Message) -> Result<()> {
        let mut games_guard = self.games.lock().unwrap();

        let body = msg.into_text()?;
        let request: GameRequest = match serde_json::from_str(&body) {
            Ok(v) => v,
            Err(_) => {
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: game::Game::new(String::from("")),
                        player_id: String::from(""),
                    })
                    .unwrap(),
                );
            }
        };

        println!("GameRequest: {:?}", request);
        let mut player_id = request.player_id.clone();

        let mut game: game::Game;
        let response_code;
        if request.new_game {
            // TODO uncomment when ready to deploy to production
            // let now = SystemTime::now();
            // let timestamp = now.duration_since(UNIX_EPOCH).expect("TIME PROBLEM");
            // let timestamp: String = String::from(timestamp.as_nanos().to_string());
            // let game_id = timestamp + &util::random_string(16);
            let game_id = util::random_string(1);
            game = game::Game::new(game_id.clone());
            games_guard.insert(game_id.clone(), game.clone());
            response_code = 0;
        } else {
            let g = match games_guard.get_mut(&request.game_id) {
                Some(x) => x,
                None => {
                    response_code = 2;
                    return self.out.send(
                        serde_json::to_string(&GameResponse {
                            error_code: response_code,
                            game: game::Game::new(String::from("")),
                            player_id: player_id,
                        })
                        .unwrap(),
                    );
                }
            };

            if request.new_player {
                if g.game_started {
                    response_code = 1;
                } else {
                    let mut player = game::Player::new();
                    let ok = g.add_player(&mut player);
                    if ok {
                        player_id = player.id;
                        response_code = 0;
                    } else {
                        response_code = 1;
                    }
                }
            } else if request.start_game {
                if g.start_game(&player_id) {
                    response_code = 0;
                } else {
                    response_code = 1;
                }
            } else {
                if !g.game_started {
                    response_code = game_step(g, &request);
                } else {
                    response_code = 1;
                }
            }

            game = g.clone();
        }

        sanitize(&mut game, &player_id);

        return self.out.send(
            serde_json::to_string(&GameResponse {
                error_code: response_code,
                game: game.clone(),
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
    let games = Arc::new(Mutex::new(HashMap::new()));

    listen("127.0.0.1:3000", |out| Server {
        out: out,
        games: games.clone(),
    })
    .unwrap();
}

fn game_step(game_guard: &mut game::Game, request: &GameRequest) -> u8 {
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
    } else {
        return 1;
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

fn sanitize(game: &mut game::Game, player_id: &String) {
    for player in game.players.iter_mut() {
        if player.id != *player_id {
            player.id = String::from("");
        }
    }
}
