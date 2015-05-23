#!/usr/bin/env ruby
require '../../lib/rg_codebreaker'

game = RgCodebreaker::Game.new
play_status = 'yes'
until play_status == 'no' do
  puts game.start
  while game.attempts do
    reply = game.compare(gets.chomp)
    puts reply
    if reply =~ /WIN/
      game.save(gets.chomp)
      puts game.statistics
      break
    elsif reply =~ /Fail/
      break
    end
  end
  puts 'Want to play again?(yes/no)'
  play_status = gets.chomp
  game.play_again(play_status)
end
