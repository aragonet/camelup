mod game;
use serde::{Deserialize, Serialize};
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
    game: &mut game::Game,
}
impl Handler for Server {
    fn on_message(&mut self, msg: Message) -> Result<()> {
        let body = msg.into_text()?;
        let request: GameRequest = match serde_json::from_str(&body) {
            Ok(v) => v,
            Err(_) => {
                return self.out.send(
                    serde_json::to_string(&GameResponse {
                        error_code: 1,
                        game: self.game.clone(),
                    })
                    .unwrap(),
                )
            }
        };
        // println!("GameRequest: {:?}", request);
        // println!("Main {:?}", self.game);
        if request.throw_dice {
            let dice = game::pyramid::throw_dice(&mut self.game.dice_pool);
            game::race_circuit::move_camel(dice.camel_id, dice.number, &mut self.game.circuit);
            self.game.players[request.player_id].points += 1;
        }

        let serialized = serde_json::to_string(&GameResponse {
            error_code: 0,
            game: self.game.clone(),
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
    let mut game = game::Game::new();

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
        game: &mut game,
    })
    .unwrap();
}
