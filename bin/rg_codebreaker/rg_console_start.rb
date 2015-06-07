#!/usr/bin/env ruby
require '../../lib/rg_codebreaker'
class ConsoleCodebreaker
  game = RgCodebreaker::Game.new
  play_status = 'yes'
  until play_status == 'no' do
    game.start
    puts "#{game.attempts} attempts left. Enter your guess:"
    while game.attempts do
      reply = game.compare(gets.chomp)
      case
        when reply == 'invalid'   then puts 'Invalid input, try again:'
        when reply.length == 1    then puts "#{game.attempts} attempts left. Hint: #{reply}"
        when reply.include?('++++') then puts "You're WIN!"; break
        when game.attempts > 0    then puts "#{game.attempts} attempts left. #{reply}"
        else                           puts "Fail! Secret code was: #{game.instance_variable_get(:@secret_code)}"; break
      end
    end
    puts 'Enter your name:'
    name = gets.chomp
    game.save(name) unless name.empty?
    game.statistics.each { |name, g| puts "Player: >#{name}< played #{g.length} games." }
    puts 'Want to play again?(y/n):'
    while play_status = gets.chomp
      case play_status
        when /y/ then game.start; break
        when /n/ then exit
        else          puts "Enter 'yes' or 'y' to start new game OR 'no' or 'n' to exit."
      end
    end
  end
end
