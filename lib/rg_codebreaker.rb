require "rg_codebreaker/version"

module RgCodebreaker
  class Game
    attr_reader :attempts
    SECRET_CODE_LENGTH = 4
    STAT_FILE_PATH = "spec/data/statistic.txt"
  
    def initialize(out, inpt)
      @out, @inpt = out, inpt
    end
    
    def start(code = generate_code)
      @secret_code = code
      @attempts = @secret_code.length * 2
    end
    
    def generate_code
      ((1..6).to_a * SECRET_CODE_LENGTH).shuffle[1..SECRET_CODE_LENGTH].join("")
    end
    
    def valid?(guess)
      guess.length == SECRET_CODE_LENGTH && guess.match(/[1-6]{4}/)
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
      total_match(guess) == 0 ? "no matches" : "+" * exact_match(guess) + "-" * number_match(guess)
    end
    
    def hint
      @secret_code[0]
    end
    
    def use_attempt
      @attempts -= 1
    end
    
    def compare(guess)
      if reply_message(guess) == "++++"
        "\"++++\"\nWIN!\nEnter your name: "
      elsif @attempts == 1
        "\"#{reply_message(guess)}\"\nNo attempts left. Fail!"
      else
        use_attempt
        "\"#{reply_message(guess)}\"\nAttempts left: #@attempts. Enter your guess: "
      end
    end
    
    def save
      name = @inpt.gets.chomp
      File.open(STAT_FILE_PATH, "a+") do |file|
        file.puts("#{name} (secret code: #@secret_code)")
      end
    end
    
    def statistics
      File.read(STAT_FILE_PATH) || "No saved results!"
    end
    
    def play_again
      message = @inpt.gets.chomp
      if message == "yes"
        start
      elsif message == "no"
        exit
      end
    end  
  end
end
