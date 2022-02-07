class VericredController < ApplicationController
  class ParentRubyObject
    attr_reader :id, :children

    def initialize(id, children)
      @id = id
      @children = children
    end
  end

  class ChildRubyObject
    attr_reader :hex_value

    def initialize
      @hex_value = SecureRandom.hex
    end
  end

  def example
    parent_objects = [].tap do |array|
      (1..1_00).map do |item_counter|
        id = item_counter
        children = Array.new(1000) { |_| ChildRubyObject.new }
        array << ParentRubyObject.new(id, children)
      end
    end

    result_ruby = nil
    result_rust = nil
    result_rust_multi = nil

    ruby_benchmark = Benchmark.measure {
      result_ruby = calculate(parent_objects)
    }

    rust_benchmark = Benchmark.measure {
      result_rust = RustLib.calculate(parent_objects)
    }

    rust_multi_benchmark = Benchmark.measure {
      result_rust_multi = RustLib.calculate_multi(parent_objects)
    }

    performance_s = ruby_benchmark.total / rust_benchmark.total
    performance_m = ruby_benchmark.total / rust_multi_benchmark.total

    if result_ruby == result_rust && result_ruby == result_rust_multi
      @text = "Sum of 100,000 SecureRandom.hex values\n\n"\
              "Ruby version total time:         #{ruby_benchmark.total.round(6)}\n\n"\
              "Rust single-threaded total time: #{rust_benchmark.total.round(6)}\n"\
              "= #{performance_s.round(2)} times faster than Ruby\n\n"\
              "Rust multi-threaded total time:  #{rust_multi_benchmark.total.round(6)}\n"\
              "= #{performance_m.round(2)} times faster than Ruby"\
    else
      @text = "Oops! Something went wrong\n\n"\
              "result_ruby: #{result_ruby}\n"\
              "result_rust: #{result_rust}\n"\
              "result_rust_multi: #{result_rust_multi}"
    end
  end

  private

  def calculate(parent_objects)
    parent_objects
      .flat_map(&:children)
      .sum do |child|
        child.hex_value.split('').sum { |c| c.to_i(base=10) }
      end
  end
end