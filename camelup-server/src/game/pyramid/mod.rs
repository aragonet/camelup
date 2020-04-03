use rand::distributions::{Distribution, Uniform};

#[derive(Debug)]
pub struct Dice {
    pub number: u8,
    pub camel_id: u8,
}

pub fn new_dice_pool() -> Vec<u8> {
    return vec![1, 2, 3];
}

// It is expected that always will be available dices
pub fn throw_dice(dice_pool: &mut Vec<u8>) -> Dice {
    let dices_left = dice_pool.len();
    let mut rng = rand::thread_rng();
    let index = Uniform::from(0..dices_left).sample(&mut rng);
    let camel_id = dice_pool[index];

    let dice_number = Uniform::from(1..4).sample(&mut rng);

    dice_pool.drain(index..index + 1);

    return Dice {
        number: dice_number,
        camel_id: camel_id,
    };
}

pub fn is_the_round_ended(dice_pool: &mut Vec<u8>) -> bool {
    return dice_pool.len() == 0;
}
