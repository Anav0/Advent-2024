use std::fs::File;
use std::io::{BufRead, BufReader};

fn prepate_permutations(arr: &Vec<isize>) -> Vec<Vec<isize>> {
    let mut permutations: Vec<Vec<isize>> = vec![];
    for i in 0..arr.len() {
        let mut variant = arr.clone();
        variant.remove(i);
        permutations.push(variant);
    }
    permutations 
}

fn main() {
    let file = File::open("day2.txt").expect("Failed to read day2.txt file");
    let buffer = BufReader::new(file);

    let mut good_seq = 0;
    for line in buffer.lines() {
        match line {
            Ok(line_str) => {
                let split: Vec<isize> = line_str.split(' ').map(|x| str::parse(x).unwrap()).collect();

                let permutations = prepate_permutations(&split);

                for arr in permutations {
                    let diffs: Vec<_> = arr.windows(2).map(|pair| pair[0] - pair[1]).collect();
                    let increasing = diffs[0] > 0;

                    let is_good_seq = diffs.into_iter()
                        .map(|v| if (increasing && v > 0 && v <= 3) || (!increasing && v < 0 && v >= -3) { true } else { false })
                        .all(|v| v);
                    if is_good_seq {
                        good_seq+=1;
                        break;
                    }
                }

            },
            Err(_) => { println!("Failed to read line of day2.txt") }
        }
    }

    println!("{}", good_seq);
}
