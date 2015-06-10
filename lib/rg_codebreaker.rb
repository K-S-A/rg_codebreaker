require_relative "rg_codebreaker/version"
require 'yaml'

module RgCodebreaker
  class Game
    attr_reader :attempts, :guess_log, :invalid, :code_length
    STAT_FILE = 'statistics.rb'

    def start(code = nil, code_length = 4)
      @code_length, @attempts, @hint, @start_time, @invalid =code_length, code_length * 2, nil, Time.now, nil
      @secret_code = code || generate_code
      @guess_log = []
      self
    end

    def compare(guess)
      case
      when guess == 'hint' then hint
      when !valid?(guess)  then @invalid = true
      else                      use_attempt; @invalid = nil; @end_time = Time.now; (@guess_log << [guess, reply_message(guess)]).last
      end
    end

    def save(name)
        stats = statistics || {}
        stats[name] = (stats[name] || []) << self
        File.open(STAT_FILE, 'w', 0776) { |file| file.write stats.to_yaml }
    end

    def statistics
      YAML.load_file(STAT_FILE) if File.exist?(STAT_FILE)
    end

    def duration
      (@end_time - @start_time).to_i
    end

    private

    def generate_code
      (1..@code_length).map { (1..6).to_a.sample(1) }.join
    end

    def valid?(guess)
      guess.length == @code_length && guess.match(/[1-6]{4}/)
    end

    def exact_match(guess)
      @secret_code.chars.zip(guess.chars).keep_if{|i| i.uniq.length == 1}.count
    end

    def total_match(guess)
      guess.chars.uniq.inject(0){ |num, chr| num += [guess.count(chr), @secret_code.count(chr)].min }
    end

    def number_match(guess)
      total_match(guess) - exact_match(guess)
    end

    def reply_message(guess)
      total_match(guess) == 0 ? "no matches" : "+" * exact_match(guess) + "-" * number_match(guess)
    end

    def use_attempt
      @attempts -= 1
    end

    def hint
      @hint = @secret_code[rand(4)] unless @hint
    end

  end
end
