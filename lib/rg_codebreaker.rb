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
      #guess = @out.gets.chomp
      #validate(guess)
      #reply_message(guess)
      #try = validate(gets.chomp)
    end
    
    def generate_code
      ((1..6).to_a * SECRET_CODE_LENGTH).shuffle[1..SECRET_CODE_LENGTH].join("")
    end
    
    def validate(guess)
      @out.puts "Code must contain 4 digits from 1 to 6." unless guess.length == SECRET_CODE_LENGTH && guess.match(/[1-6]{4}/)
    end
    
    def exact_match(guess)
      exact_num = 0
      (0..3).each { |i| exact_num += 1 if @secret_code[i] == guess[i] }
      exact_num
    end
    
    def total_match(guess)
      guess = "" + guess
      total_num = 0
      @secret_code.each_char do |i|
        if  guess.include?(i)
          total_num += 1
           guess[guess.index(i)] = ""
        end
      end
      total_num
    end
    
    def number_match(guess)
      total_match(guess) - exact_match(guess)
    end
    
    def reply_message(guess)
      @out.puts "+" * exact_match(guess) + "-" * number_match(guess)
    end
  
  end
end
