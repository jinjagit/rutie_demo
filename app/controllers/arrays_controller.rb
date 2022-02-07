class ArraysController < ApplicationController
  require 'benchmark'

  def reverse
    array = ['Ruby', 'to', 'Rust']
    reversed = RustLib.reverse(array)

    @text = "Pass array from Ruby to Rust  => #{array.inspect}\n"\
            "Return reversed array to Ruby => #{reversed.inspect}"
  end

  def blocked_words
    blocked_words =[]

    # Currently 618 words in pl.txt
    File.readlines(Rails.root.join("config/blocked_words/pl.txt")).each do |line|
      blocked_words << line.strip
    end

    words_to_find = get_random_items(blocked_words, 5)
    text_array = create_array_including_supplied_words(10000, words_to_find)

    result_ruby = nil
    result_rust = nil
    result_rust_multi = nil

    ruby_benchmark = Benchmark.measure {
      result_ruby = find_blocked_words(text_array, blocked_words)
    }

    rust_benchmark = Benchmark.measure {
      result_rust = RustLib.find_blocked_words(text_array, blocked_words)
    }

    rust_multi_benchmark = Benchmark.measure {
      result_rust_multi = RustLib.find_blocked_words_multi(text_array, blocked_words)
    }

    performance_s = ruby_benchmark.total / rust_benchmark.total
    performance_m = ruby_benchmark.total / rust_multi_benchmark.total

    check_ruby = check_array_contains_elements(result_ruby, words_to_find)

    if check_ruby && (result_ruby == result_rust && result_ruby == result_rust_multi)
      @text = "Array of #{text_array.length} strings compared to array of #{blocked_words.length} strings\n"\
              "= #{text_array.length * blocked_words.length} comparisons\n\n"\
              "Ruby version total time:         #{ruby_benchmark.total.round(6)}\n\n"\
              "Rust single-threaded total time: #{rust_benchmark.total.round(6)}\n"\
              "= #{performance_s.round(2)} times faster than Ruby\n\n"\
              "Rust multi-threaded total time:  #{rust_multi_benchmark.total.round(6)}\n"\
              "= #{performance_m.round(2)} times faster than Ruby"\
    else
      @text = "Oops! Something went wrong\n\n"\
              "check_ruby: #{check_ruby}\n"\
              "result_ruby: #{result_ruby}\n"\
              "result_rust: #{result_rust}\n"\
              "result_rust_multi: #{result_rust_multi}"
    end
  end

  private

  def find_blocked_words(text_array, blocked_words)
    found_words = []

    text_array.each do |word|
      found_words << word if blocked_words.include? word
    end

    found_words
  end

  def check_array_contains_elements(array, elements)
    passed = true

    elements.each do |el|
      passed = false unless array.include? el
    end

    passed
  end

  # Includes zero: e.g. n_unique_integers(9, 3)
  # will return 3 unique integers, randomly chosen from the range 0..8
  def n_unique_integers (from_n, get_n)
    check_unique_selection_limit(from_n, get_n)

    integers = []

    loop do
      int = rand(from_n)
      integers << int unless integers.include? int
      break if integers.length == get_n
    end

    integers
  end

  def get_random_items(array, n_items)
    check_unique_selection_limit(array.length, n_items)

    indices = n_unique_integers(array.length, n_items)
    selected = []

    n_items.times do |i|
      selected << array[indices[i]]
    end

    selected
  end

  def check_unique_selection_limit(a, b)
    raise StandardError.new "Cannot return more unique items than exist" if b > a
  end

  def replace_items_in_array(array, new_items)
    check_unique_selection_limit(array.length, new_items.length)

    indices = n_unique_integers(array.length, new_items.length)

    new_items.length.times do |i|
      array[indices[i]] = new_items[i]
    end

    array
  end

  def create_array_of_random_strings(n)
    array = []

    n.times do
      num = rand(10) + 1
      array << (0...num).map { ('a'..'z').to_a[rand(26)] }.join
    end

    array
  end

  def create_array_including_supplied_words(n_words, supplied_words)
    array_of_random_strings = create_array_of_random_strings(n_words)
    replace_items_in_array(array_of_random_strings, supplied_words)
  end

  def all_benchmarks (benchmark)
    "real: #{benchmark.real}\n"\
    "cstime: #{benchmark.cstime}\n"\
    "cutime: #{benchmark.cutime}\n"\
    "stime: #{benchmark.stime}\n"\
    "utime: #{benchmark.utime}\n"\
    "total: #{benchmark.total}\n"
  end
end