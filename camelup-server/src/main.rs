mod game;
mod util;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, Mutex};
use std::time::{SystemTime, UNIX_EPOCH};
use std::{
    thread,
    time::{Duration, Instant},
};
use ws::{listen, CloseCode, Handler, Message, Result, Sender};

#[derive(Serialize, Deserialize, Debug, Default)]
struct GameRequest {
    game_id: String,
    new_game: bool,
    new_player: bool,
    start_game: bool,
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
    games: Arc<Mutex<HashMap<String, game::Game>>>,
    connections: Arc<Mutex<HashMap<String, Vec<Sender>>>>,
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

            save_game_connection(&self.out, &g.id, &mut self.connections.lock().unwrap());

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
                if g.game_started {
                    response_code = game_step(g, &request);
                } else {
                    response_code = 8;
                }
            }

            g.update_time();
            game = g.clone();
            if let Some(conns) = self.connections.lock().unwrap().get(&game.id) {
                for i in 0..conns.len() {
                    let conn = conns.get(i).unwrap();
                    if conn == &self.out {
                        continue;
                    }

                    let player = g.players.get(i).unwrap();
                    let mut game_aux = game.clone();
                    sanitize(&mut game_aux, &player.id);

                    match conn.send(
                        serde_json::to_string(&GameResponse {
                            error_code: response_code,
                            game: game_aux.clone(),
                            player_id: String::from(""),
                        })
                        .unwrap(),
                    ) {
                        Ok(_) => (),
                        Err(e) => println!("Error: {:?}", e),
                    }
                }
            }
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
    let conns = Arc::new(Mutex::new(HashMap::new()));

    {
        let g = games.clone();
        let c = conns.clone();
        // TODO if this thread panics, main stills working.
        thread::spawn(move || {
            let wait_time = Duration::from_secs(60 * 5);
            loop {
                clear_unused_games(g.clone(), c.clone());
                thread::sleep(wait_time);
            }
        });
    }

    listen("0.0.0.0:8001", |out| Server {
        out: out,
        games: games.clone(),
        connections: conns.clone(),
    })
    .unwrap();
}

fn game_step(game_guard: &mut game::Game, request: &GameRequest) -> u8 {
    if game_guard.game_ended {
        return 3;
    }

    let player_id = match game_guard
        .players
        .iter()
        .position(|x| x.id == request.player_id)
    {
        Some(id) => (id + 1) as u8,
        None => {
            return 4;
        }
    };

    if !game_guard.is_player_turn(player_id) {
        return 5;
    }

    if request.throw_dice {
        game_guard.players[(player_id - 1) as usize].points += 1;
        let dice =
            game::pyramid::throw_dice(&mut game_guard.dice_pool, &mut game_guard.thrown_dices);
        game::race_circuit::move_camel(dice.camel_id, dice.number, &mut game_guard.circuit);
    } else if request.get_camel_round_card != 0 {
        if request.get_camel_round_card > game_guard.camels.len() as u8 {
            return 6;
        }

        game::round_market::get_card(
            player_id,
            request.get_camel_round_card,
            &mut game_guard.round_cards,
        );
    } else {
        return 7;
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

fn save_game_connection(
    conn: &Sender,
    game_id: &String,
    connections: &mut HashMap<String, Vec<Sender>>,
) {
    if let Some(game_connections) = connections.get_mut(game_id) {
        for c in game_connections.iter() {
            if c == conn {
                return;
            }
        }
        game_connections.push(conn.clone());
    } else {
        connections.insert(game_id.clone(), vec![conn.clone()]);
    }
}

fn clear_unused_games(
    games: Arc<Mutex<HashMap<String, game::Game>>>,
    connections: Arc<Mutex<HashMap<String, Vec<Sender>>>>,
) {
    let mut games = games.lock().unwrap();
    let mut connections = connections.lock().unwrap();

    for game_t in &mut games.clone().iter_mut() {
        if game_t.1.spoiled_connection() {
            if let Some(conns) = connections.get(game_t.0) {
                for conn in conns.into_iter() {
                    conn.close(CloseCode::Away);
                }

                connections.remove_entry(game_t.0);
            }
            games.remove_entry(game_t.0);
        }
    }
}
