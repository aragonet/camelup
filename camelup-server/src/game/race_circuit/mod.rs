// Camel is expecte to have not ended the race.
// Count is expected to be between 1 and 3. Both inclusives.
// Si Count + position es mayor que el final, reducir al final (box 16)
pub fn move_camel(camel_id: u8, count: u8, circuit: &mut Vec<Vec<u8>>) {
    let mut box_index: usize = 0;
    let mut camels_index: usize = 0;
    'outer: for (i, circuit_box) in circuit.iter().enumerate() {
        for (j, c_id) in circuit_box.iter().enumerate() {
            if c_id == &camel_id {
                box_index = i;
                camels_index = j;
                break 'outer;
            }
        }
    }

    let mut a: Vec<u8> = vec![];
    for i in &mut circuit[box_index][camels_index..] {
        a.push(*i);
    }

    let mut last_position = box_index + count as usize;
    if last_position >= 16 {
        last_position = 16;
    }
    circuit[last_position].extend(a);
    circuit[box_index].drain(camels_index..);
}
