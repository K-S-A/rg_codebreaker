require 'spec_helper'

module RgCodebreaker
  describe Game do
    let(:game) { Game.new }
    let(:start) { game.start('1234') }
    let(:code) { game.send(:generate_code) }
    test_cases = [[0, 0, 0, "1122", "3344", "no matches"], [1, 1, 0, "1122", "1333", "+"], [1, 0, 1, "1122", "3331", "-"],\
                  [2, 2, 0, "1122", "3123", "++"], [2, 1, 1, "1122", "2133", "+-"], [2, 0, 2, "1122", "3213", "--"],\
                  [3, 3, 0, "1122", "1322", "+++"], [3, 2, 1, "1122", "2123", "++-"], [3, 1, 2, "1122", "2221", "+--"],\
                  [3, 0, 3, "1122", "2213", "---"], [4, 4, 0, "1122", "1122", "++++"], [4, 2, 2, "1122", "2121", "++--"],\
                  [4, 1, 3, "1123", "1312", "+---"], [4, 0, 4, "1122", "2211", "----"]]
                  # [total_num, exact_num, number_num, @secret_code, guess, reply_message] 
    
    context '#start' do
      before { start }
      it 'should set secret code' do
        expect(game.instance_variable_get(:@secret_code)).to eq('1234')
      end     
      it 'should set the maximum number of attempts equal to 8' do
        expect(game.instance_variable_get(:@attempts)).to eq(8)
      end
      it "should return \"Maximum attempts - 8. Enter your guess:\"" do
        expect(game.start).to eq("Maximum attempts - #{game.attempts}. Enter your guess:")
      end
      it 'should set instance variable @hint to true' do
        expect(game.instance_variable_get(:@hint)).to be_falsey
      end 
    end
    
    context '#generate_code' do
      it 'generates secret code' do
        expect(code).not_to be_empty
      end
      it "saves 4 numbers secret code" do
        expect(code).to have(4).items
      end
      it 'saves secret code with numbers from 1 to 6' do
        expect(code).to match(/[1-6]{4}/)
      end
      it 'should generate unique code that not equal to previous' do
        expect(code).not_to eq(game.send(:generate_code))
      end
    end
    
    context '#valid?' do
      context 'should be truthy if guess' do
        it 'have 4 numbers' do
          expect(game.send(:valid?, "1234")).to be_truthy
        end
      end
      context 'should be falsey if guess:' do
        it 'longer than expected' do
          expect(game.send(:valid?, "12345")).to be_falsey
        end
        it 'shorter than expected' do
          expect(game.send(:valid?, "123")).to be_falsey
        end
        it 'have not only numbers' do
          expect(game.send(:valid?, "123d")).to be_falsey
        end
        it 'have numbers outside range 1..6' do
          expect(game.send(:valid?, "7980")).to be_falsey
        end
      end
    end
    
    context '#exact_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[1]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.send(:exact_match, test_case[4])).to eq(test_case[1])
        end
      end
    end
    
    context '#total_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[0]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.send(:total_match, test_case[4])).to eq(test_case[0])
        end
      end
    end
    
    context '#number_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[2]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.send(:number_match, test_case[4])).to eq(test_case[2])
        end
      end
    end
    
    context '#reply_message' do
      test_cases.each do |test_case|
        it "should return \"#{test_case[5]}\" if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.send(:reply_message, test_case[4])).to eq(test_case[5])
        end
      end
    end
    
    context '#hint' do
      before { start }
      it 'should return first number of secret code' do
        expect(game.instance_variable_get(:@secret_code)).to include(game.send(:hint))
      end
      it 'should be used only one time' do
        expect(game.send(:hint)).to eq(game.send(:hint))
      end
    end
    
    context '#attempts' do
      it 'should return number of maximum attempts' do
        start
        expect(game.attempts).to eq(8)
      end
    end
    
    context '#use_attempt' do
      it 'should decrease number of attempts by 1' do
        start
        expect{ 3.times{ game.send(:use_attempt) } }.to change { game.attempts }.by(-3)
      end
    end
    
    context '#compare' do
      before { start }
      it 'should return "Invalid guess, try again:" if guess have wrong format' do
        expect(game.compare('94j2')).to eq("Invalid guess, try again:")
      end
      it 'should call hint if received "hint"' do
        allow(game).to receive(:hint).and_return("1").once
        expect(game.compare('hint')).to eq('>>>1<<<. Enter your guess:')
      end
      it "should return \"\"++++\" WIN! Enter your name: \" if code is broken within allowable number of attempts" do
        expect(game.compare("1234")).to eq("\"++++\"\nWIN!\nEnter your name: ")
      end
      it "should return \"\"++--\" Attempts left: 7. Enter your guess: \" if code is not broken and some attempts left" do
        expect(game.compare("1243")).to eq("\"++--\"\nAttempts left: 7. Enter your guess: ")
      end
      it "should return \"\"++--\" No attempts left. Fail!\" if code is not broken and no attempts left" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.compare("1243")).to match(/\"\+\+\-\-\"\nNo attempts left. Fail!\nSecret code was:/)
      end
    end
    
    context '#save' do
      it 'should call #open with argument "a+"' do
        expect(File).to receive(:open).with("statistic.txt", "a+").once
        game.save('Player')
      end
    end
    
    context '#statistics' do
      it 'should call #read with path to statistics file as argument' do
        expect(File).to receive(:read).with("statistic.txt").once
        game.statistics
      end
      it 'should return "No saved results!" if file is not available' do
        allow(File).to receive(:read).with("statistic.txt").and_return(nil)
        expect(game.statistics).to eq("###Statistics:###\nNo saved results!")
      end
    end
    
    context '#play_again' do
      it 'should start new game if receives "yes"' do
        expect(game).to receive(:start).once
        game.play_again('yes')
      end
      it 'should exit game when gets "no"' do
        expect{ game.play_again('no') }.to raise_error SystemExit
      end
    end  
  end
end
