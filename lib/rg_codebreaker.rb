require_relative "rg_codebreaker/version"
require 'yaml'

module RgCodebreaker
  class Game
    attr_reader :attempts, :guess_log, :invalid, :code_length, :win
    STAT_FILE = 'statistics.rb'

    def start(code = nil, code_length = 4, rng = 1..6)
      @code_length, @attempts, @rng, @start_time =code_length, code_length * 2, rng, Time.now
      @hint, @invalid, @win = nil, nil, nil
      @secret_code = code || generate_code
      @guess_log = []
      self
    end

    def compare(guess)
      case
      when guess == 'hint' then hint
      when !valid?(guess)  then @invalid = true
      else
        use_attempt; @invalid = nil; @end_time = Time.now
        @win = true if reply_message(guess).length == @code_length && !reply_message(guess).match(/-/)
        (@guess_log << [guess, reply_message(guess)]).last
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
      (1..@code_length).map { @rng.to_a.sample(1) }.join
    end

    def valid?(guess)
      guess.length == @code_length && guess.match(/[#{@rng.first}-#{@rng.last}]{#{@code_length}}/)
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
      @hint = @secret_code[rand(@code_length)] unless @hint
    end

  end
end
