require "rg_codebreaker/version"

module RgCodebreaker
  class Game
    SECRET_CODE_LENGTH = 4
    STAT_FILE_PATH = "spec/data/statistic.txt"
    
    def start(code = generate_code)
      @secret_code = code
      @attempts = @secret_code.length * 2
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
    
    def hint
      @secret_code[0]
    end
    
    def save(name)
      File.open(STAT_FILE_PATH, "a+") do |file|
        file.puts("#{name} (secret code: #@secret_code)")
      end
    end
    
    def statistics
      File.read(STAT_FILE_PATH) || "No saved results!"
    end
    
    def play_again(request)
      case request
        when "yes" then start
        when "no"  then exit
      end
    end
    
    private

    def generate_code
      (1..SECRET_CODE_LENGTH).map { (1..6).to_a.sample(1) }.join
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
  end
end
