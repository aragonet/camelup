use rand::distributions::Alphanumeric;
use rand::{thread_rng, Rng};

pub fn random_string(n: usize) -> String {
    return thread_rng().sample_iter(&Alphanumeric).take(n).collect();
}
