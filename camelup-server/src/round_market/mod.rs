#[derive(Debug, Clone)]
pub struct Card {
    pub points: u8,
    pub player_id: u8,
}

// It expects to receive a valid person_id
// It expects to receive a valid camel_id, cause there will be a card to get
pub fn get_card(player_id: u8, camel_id: u8, round_market_cards: &mut Vec<Vec<Card>>) {
    let camel_id = (camel_id - 1) as usize;
    let cards = &mut round_market_cards[camel_id];
    for card in cards {
        if card.player_id == 0 {
            card.player_id = player_id;
            break;
        }
    }
}

pub fn new_cards() -> Vec<Vec<Card>> {
    return vec![
        vec![
            Card {
                points: 5,
                player_id: 0
            },
            Card {
                points: 3,
                player_id: 0
            },
            Card {
                points: 2,
                player_id: 0
            },
        ];
        3
    ];
}

pub fn give_out_points(
    round_market_cards: &Vec<Vec<Card>>,
    players: &mut Vec<super::Player>,
    circuit: &Vec<Vec<u8>>,
) {
    let mut first_camel: u8 = 0;
    let mut second_camel: u8 = 0;
    'outer: for i in 0..circuit.len() {
        let i = circuit.len() - 1 - i;
        let c_box = &circuit[i];
        for c in 0..c_box.len() {
            let c = c_box.len() - 1 - c;
            if first_camel == 0 {
                first_camel = c_box[c] as u8;
                continue;
            } else if second_camel == 0 {
                second_camel = c_box[c] as u8;
                continue;
            }
            break 'outer;
        }
    }

    println!("1. {} 2. {}", first_camel, second_camel);
    println!("{:?}", round_market_cards);

    let mut players_points: Vec<i8> = vec![0; players.len()];
    for camel_id in 0..round_market_cards.len() {
        let camel_cards = &round_market_cards[camel_id];
        for card in camel_cards {
            if card.player_id != 0 {
                let camel_id = (camel_id + 1) as u8;
                let card_player_id = (card.player_id - 1) as usize;
                if first_camel == camel_id {
                    players_points[card_player_id] += card.points as i8;
                } else if second_camel == camel_id {
                    players_points[card_player_id] += 1;
                } else {
                    players_points[card_player_id] -= 1;
                }
            }
        }
    }

    println!("{:?}", players_points);

    for i in 0..players.len() {
        let mut points = players_points[i];
        if points < 0 {
            points = 0;
        }

        players[i].points = points as u8;
    }
}
