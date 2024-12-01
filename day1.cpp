
#include <iostream>
#include <fstream>
#include <string>
#include <string_view>
#include <vector>
#include <sstream>
#include <ranges>
#include <cmath>
#include <algorithm>
#include <print>
#include <map>

int main() {
    std::ifstream file("day1.txt");
    if (!file.is_open()) {
        std::cerr << "Error: Could not open file.\n";
        return EXIT_FAILURE;
    }

		std::vector<long> left, right;
		std::map<int, int> freq;
    std::string line;
    while (std::getline(file, line)) {
			std::vector<std::string> parts;
			std::string word;
			for(char ch : line) {
					if(std::isspace(ch)) {
						if(word.empty()) { continue; }
							parts.push_back(word);
							word.clear();
					}else {
						word.push_back(ch);
					}
			}
			if(!word.empty()) {
				parts.push_back(word);
			}

			auto l = parts.at(0);
			auto r = parts.at(1);

			long l_number = 0;
			long r_number = 0;

	    auto [ptr, res] = std::from_chars(l.data(), l.data() + l.size(), l_number);
			if (res == std::errc::result_out_of_range) {
				std::print("Failed to parse: '{}'", l);
				return -1;
			}
	    auto [ptr2, res2] = std::from_chars(r.data(), r.data() + r.size(), r_number);
			if (res2 == std::errc::result_out_of_range) {
				std::print("Failed to parse: '{}'", r);
				return -1;
			}

			left.push_back(l_number);
			right.push_back(r_number);
			freq[r_number]++;
    }

		if(left.size() != right.size()) {
				std::print("Size of columns is not the same!");
				return -1;
		}
		std::sort(left.begin(), left.end());
		std::sort(right.begin(), right.end());

		long total = 0;
		long total_freq = 0;
		for(long i = 0; i < left.size(); i++) {
			long l = left.at(i);
			long r = right.at(i);
			long d = std::abs(l - r);
			total+=d;

			if(freq.contains(l)) {
					total_freq += l * freq.at(l);
			}
		}

		std::println("total: '{}'", total);
		std::println("total_freq: '{}'", total_freq);

    return EXIT_SUCCESS;
}

