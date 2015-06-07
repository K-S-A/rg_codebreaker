require_relative "rg_codebreaker/version"
require 'yaml/dbm'

module RgCodebreaker
  class Game
    attr_reader :attempts

    def start(code = nil, code_length = 4)
      @code_length, @attempts, @hint =code_length, code_length * 2, nil
      @secret_code = code || generate_code
      @db = YAML::DBM.open('statistic', 666, YAML::DBM::WRCREAT)
      self
    end

    def compare(guess)
      case
      when guess == 'hint' then hint
      when !valid?(guess)  then 'invalid'
      else                 use_attempt; [guess, reply_message(guess)]
      end
    end

    def save(name)
        stats = @db['stats'] || {}
        stats[name] = (stats[name] || []) << self
        @db['stats'] = stats
    end

    def statistics
      @db['stats']
    end

    private
    def generate_code
      (1..@code_length).map { (1..6).to_a.sample(1) }.join
    end

    def valid?(guess)
      guess.length == @code_length && guess.match(/[1-6]{4}/)
    end

    def exact_match(guess)
      exact_num = 0
      @secret_code.chars.each.with_index { |x, i| exact_num += 1 if @secret_code[i] == guess[i] }
      exact_num
    end

    def total_match(guess)
      total_num = 0
      guess.chars.uniq.each { |i| total_num += [guess.count(i), @secret_code.count(i)].min }
      total_num
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
