require 'spec_helper'

module RgCodebreaker
  describe Game do  
    let(:out) { double("out").as_null_object }
    let(:inpt) { double("inpt").as_null_object }
    let(:game) { Game.new(out, inpt) }
    let(:start) { game.start('1234') }
    let(:code) { game.generate_code }
    test_cases = [[0, 0, 0, "1122", "3344", "no matches"], [1, 1, 0, "1122", "1333", "+"], [1, 0, 1, "1122", "3331", "-"], [2, 2, 0, "1122", "3123", "++"], [2, 1, 1, "1122", "2133", "+-"], [2, 0, 2, "1122", "3213", "--"], [3, 3, 0, "1122", "1322", "+++"], [3, 2, 1, "1122", "2123", "++-"], [3, 1, 2, "1122", "2221", "+--"], [3, 0, 3, "1122", "2213", "---"], [4, 4, 0, "1122", "1122", "++++"], [4, 2, 2, "1122", "2121", "++--"], [4, 1, 3, "1123", "1312", "+---"], [4, 0, 4, "1122", "2211", "----"]] # [total, exact, number matches, secret code, guess, "+-"] 
    
    context '#start' do
      before { start }
      it 'should set secret code' do
        expect(game.instance_variable_get(:@secret_code)).to eq('1234')
      end     
      it 'should set the maximum number of attempts equal to 8' do
        expect(game.attempts).to eq(8)
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
        expect(code).not_to eq(game.generate_code)
      end
    end
    
    context '#valid?' do
      context 'should be truthy if guess' do
        it 'have 4 numbers' do
          expect(game.valid?('1234')).to be_truthy
        end
      end
      context 'should be falsey if guess:' do
        it 'longer than expected' do
          expect(game.valid?("12345")).to be_falsey
        end
        it 'shorter than expected' do
          expect(game.valid?("123")).to be_falsey
        end
        it 'have not only numbers' do
          expect(game.valid?("123d")).to be_falsey
        end
        it 'have numbers outside range 1..6' do
          expect(game.valid?("7980")).to be_falsey
        end
      end
    end
    
    context '#exact_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[1]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.exact_match(test_case[4])).to eq(test_case[1])
        end
      end
    end
    
    context '#total_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[0]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.total_match(test_case[4])).to eq(test_case[0])
        end
      end
    end
    
    context '#number_match' do
      test_cases.each do |test_case|
        it "should return #{test_case[2]} if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.number_match(test_case[4])).to eq(test_case[2])
        end
      end
    end
    
    context '#reply_message' do
      test_cases.each do |test_case|
        it "should return \"#{test_case[5]}\" if #{test_case[1]} exact and #{test_case[2]} number matches" do
          game.start(test_case[3])
          expect(game.reply_message(test_case[4])).to eq(test_case[5])
        end
      end
    end
    
    context '#hint' do
      it 'should return first number of secret code' do
        start
        expect(game.hint).to eq("1")
      end
    end
    
    context '#use_attempt' do
      it 'should decrease number of attempts by 1' do
        start
        expect{ 3.times{ game.use_attempt } }.to change { game.attempts }.by(-3)
      end
    end
    
    context '#compare' do
      before { start }
      it "should return \"\"++++\" WIN! Enter your name: \" if code is broken within allowable number of attempts" do
        expect(game.compare("1234")).to eq("\"++++\"\nWIN!\nEnter your name: ")
      end
      it "should return \"\"++--\" Attempts left: 7. Enter your guess: \" if code is not broken and some attempts left" do
        expect(game.compare("1243")).to eq("\"++--\"\nAttempts left: 7. Enter your guess: ")
      end
      it "should return \"\"++--\" No attempts left. Fail!\" if code is not broken and no attempts left" do
        game.instance_variable_set(:@attempts, 1)
        expect(game.compare("1243")).to eq("\"++--\"\nNo attempts left. Fail!")
      end
    end
    
    context '#save' do
      it 'should save player name from input' do
        expect(inpt).to receive(:gets).once
        game.save
      end
      it 'should call #open with argument "a+"' do
        allow(File).to receive(:open).with("spec/data/statistic.txt", "a+").and_return(nil)
        expect(File).to receive(:open).with("spec/data/statistic.txt", "a+").once
        game.save
      end
    end
    
    context '#statistics' do
      it 'should call #read with path to statistics file as argument' do
        expect(File).to receive(:read).with("spec/data/statistic.txt").once
        game.statistics
      end
      it 'should return "No saved results!" if file is not available' do
        allow(File).to receive(:read).with("spec/data/statistic.txt").and_return(nil)
        expect(game.statistics).to eq("No saved results!")
      end
    end
    
    context '#play_again' do
      it 'should' do
        
      end
    end
      

      
      
    
  end
end


=begin    
    context '#play_again' do #???
      it 'should output "Win!" if secret code is broken' do
        allow(inpt).to receive(:gets).and_return('1234')
        expect(out).to receive(:puts).with("Win!").once
        start
      end
      it 'should output "Want to paly again?(y/n): " if secret code is broken' do
        allow(inpt).to receive(:gets).and_return('1234')
        expect(out).to receive(:puts).with("Want to paly again?(y/n): ").once
        start
      end
      it 'should start new game when gets "y"' do
        allow(inpt).to receive(:gets).and_return('1234', 'y')
        expect(out).to receive(:puts).with(/Welcome to CODEBREAKER!\nPlease, enter your guess \(length - 4/).twice
        start
      end
      it 'should output "Exit." when gets "n"' do
        allow(inpt).to receive(:gets).and_return('1234', 'n')
        expect{start}.to raise_error SystemExit
      end
    end
=end

=begin
      xit 'should output "Welcome to CODEBREAKER! Please, enter your guess (length - 4"' do
        expect(out).to receive(:puts).with(/Welcome to CODEBREAKER!\nPlease, enter your guess \(length - 4/).once
        start
      end
      xit 'should output "maximum attempts - 8"' do
        expect(out).to receive(:puts).with(/maximum attempts - 8/).once
        start
      end
      context 'while receive invalid input' do
        xit 'should output message "Code must contain 4 digits from 1 to 6."' do
          allow(inpt).to receive(:gets).and_return('77777')
          expect(out).to receive(:puts).with('Code must contain 4 digits from 1 to 6.').once
          start
        end
      end
=end

