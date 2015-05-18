require "rg_codebreaker/version"

module RgCodebreaker
  class Game
    attr_reader :attempts
    SECRET_CODE_LENGTH = 4
  
    def initialize(out)
      @out = out
      @attempts = SECRET_CODE_LENGTH * 2
    end
    
    def start(code = generate_code)
      @secret_code = code
      @out.puts "Welcome to CODEBREAKER!\nPlease, enter your guess (length - #{SECRET_CODE_LENGTH}, maximum attempts - #@attempts): "
      #try = validate(gets.chomp)
    end
    
    def generate_code
      ((1..6).to_a * SECRET_CODE_LENGTH).shuffle[0..SECRET_CODE_LENGTH - 1].join("")
    end
    
    def validate(guess)
      @out.puts "Code must contain 4 digits from 1 to 6." unless guess.length == SECRET_CODE_LENGTH && guess.match(/[1-6]{4}/)
    end
    
    def exact_match(guess)
      exact_num = 0
      (0..3).each do |i|
        exact_num += 1 if @secret_code[i] == guess[i]
      end
      exact_num
    end
    
    def total_match(guess)
      gues = "" + guess
      total_num = 0
      @secret_code.each_char do |i|
        if gues.include?(i)
          total_num += 1
          gues[gues.index(i)] = ""
        end
      end
      total_num
    end
    
    def number_match(guess)
      total_match(guess) - exact_match(guess)
    end
  
  end
end
