require "rg_codebreaker/version"

module RgCodebreaker
  class Game
  attr_reader :secret_code
#    def initialize
#      
#    end
    
    def start
      @secret_code = ""
      4.times { @secret_code << ("1".."6").to_a.shuffle.last }
    end
  
  end
end
