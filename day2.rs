use std::fs::File;
use std::io::{BufRead, BufReader};

fn main() {
    let file = File::open("day2_t.txt").expect("Failed to read day2.txt file");
    let buffer = BufReader::new(file);

    let mut good_seq = 0;
    for line in buffer.lines() {
        match line {
            Ok(line_str) => {
                let split: Vec<isize> = line_str.split(' ').map(|x| str::parse(x).unwrap()).collect();
                let diffs: Vec<_>     = split.windows(2).map(|pair| pair[0] - pair[1]).collect();

                let increasing = diffs[0] > 0;

                let tmp: Vec<_> = diffs.clone().into_iter()
                    .map(|v| if (increasing && v > 0 && v <= 3) || (!increasing && v < 0 && v >= -3) { true } else { false })
                    .collect();

                let is_good_seq = tmp.clone().into_iter().all(|v| v);
                println!("{:?} {:?} {:?} {:?}", line_str, diffs, tmp, is_good_seq);

                if is_good_seq {
                    good_seq+=1;
                }

            },
            Err(_) => { println!("Failed to read line of day2.txt") }
        }
    }

    println!("{}", good_seq);
}
