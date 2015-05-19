require 'spec_helper'

module RgCodebreaker
  describe Game do
  
    let(:out) { double("out").as_null_object }
    let(:inpt) { double("inpt").as_null_object }
    let(:game) { Game.new(out, inpt) }
    let(:start) { game.start('1234') }
    subject(:code) { game.generate_code }
    #subject { game.instance_variable_get(:@secret_code) }
    
    context '#start' do
      it 'should output "Welcome to CODEBREAKER! Please, enter your guess (length - 4"' do
        expect(out).to receive(:puts).with(/Welcome to CODEBREAKER!\nPlease, enter your guess \(length - 4/).once
        start
      end
      it 'should set the maximum number of attempts equal to 8' do
        expect(game.attempts).to eq(8)
      end
      it 'should output "maximum attempts - 8"' do
        expect(out).to receive(:puts).with(/maximum attempts - 8/).once
        start
      end
      context 'while receive invalid input' do
        it 'should output message "Code must contain 4 digits from 1 to 6."' do
          allow(inpt).to receive(:gets).and_return('77777')
          expect(out).to receive(:puts).with('Code must contain 4 digits from 1 to 6.').once
          start
        end
      end
      context 'when valid guess submitted' do
        it 'should output first number of secret code if gets "hint"' do
          allow(inpt).to receive(:gets).and_return('hint')
          expect(out).to receive(:puts).with('1').once
          start
        end
        it 'should output "no matches" if no matches' do
          allow(inpt).to receive(:gets).and_return('5555')
          expect(out).to receive(:puts).with("no matches").once
          start
        end
        it 'should output "+-" if 1 exact and 1 number matches' do
          allow(inpt).to receive(:gets).and_return('1313')
          expect(out).to receive(:puts).with("+-").once
          start
        end
        it 'should output "++-" if 2 exact and 1 number matches' do
          allow(inpt).to receive(:gets).and_return('1253')
          expect(out).to receive(:puts).with("++-").once
          start
        end
        it 'should output "----" if 4 number matches' do
          allow(inpt).to receive(:gets).and_return('4321')
          expect(out).to receive(:puts).with("----").once
          start
        end
        it 'should output "++--" if 2 exact and 2 number matches' do
          allow(inpt).to receive(:gets).and_return('1243')
          expect(out).to receive(:puts).with("++--").once
          start
        end
        it 'should output "++++" if secret code is broken' do
          allow(inpt).to receive(:gets).and_return('1234')
          expect(out).to receive(:puts).with("++++").once
          start
        end
        
      end
    end
    
    context '#play_again' do
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
    
    context '#generate_code' do
      it 'generates secret code' do
        expect(code).not_to be_empty
      end
      it "saves 4 numbers secret code" do
        expect(code).to have(4).items
      end
      it 'saves secret code with numbers from 1 to 6' do
        expect(code).to match(/[1-6]+/)
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
      before { game.start('1232') }  
      it 'should return 4 if guess match secret code' do
        expect(game.exact_match('1232')).to eq(4)
      end
      it 'should return 3 if 3 exact matches' do
        expect(game.exact_match('1235')).to eq(3)
      end
      it 'should return 2 if 2 exact matches' do
        expect(game.exact_match('1255')).to eq(2)
      end
      it 'should return 3 if 1 exact match' do
        expect(game.exact_match('1555')).to eq(1)
      end
      it 'should return 0 if no exact matches' do
        expect(game.exact_match('5555')).to eq(0)
      end
    end
    
    context '#total_match' do
      context 'with numbers that appear once' do
        before { game.start('1234') } 
        it 'should return 4 if 4 matches' do
          expect(game.total_match('4321')).to eq(4)
        end
        it 'should return 3 if 3 matches' do
          expect(game.total_match('4325')).to eq(3)
        end
        it 'should return 2 if 2 matches' do
          expect(game.total_match('5325')).to eq(2)
        end
        it 'should return 1 if 1 matches' do
          expect(game.total_match('5525')).to eq(1)
        end
        it 'should return 0 if 0 matches' do
          expect(game.total_match('5555')).to eq(0)
        end
      end
      context 'with numbers that appear twice' do
        before { game.start('1334') } 
        it 'should return 3 if 3 matches' do
          expect(game.total_match('1243')).to eq(3)
        end
        it 'should return 2 if 2 matches' do
          expect(game.total_match('2324')).to eq(2)
        end
        it 'should return 1 if 1 matches' do
          expect(game.total_match('3222')).to eq(1)
        end
      end
    end
    
    context '#number_match' do
      context 'with numbers that appear once' do
        before { start } 
        it 'should return 4 if 4 number matches' do
          expect(game.number_match('4321')).to eq(4)
        end
        it 'should return 3 if 1 exact and 3 number matches' do
          expect(game.number_match('1423')).to eq(3)
        end
        it 'should return 2 if 2 exact and 2 number matches' do
          expect(game.number_match('1243')).to eq(2)
        end
        it 'should return 0 if 3 exact and 0 number matches' do
          expect(game.number_match('1235')).to eq(0)
        end
      end
      context 'with numbers that appear twice' do
        before { game.start('1123') } 
        it 'should return 4 if 4 number matches' do
          expect(game.number_match('2311')).to eq(4)
        end
        it 'should return 3 if 1 exact and 3 number matches' do
          expect(game.number_match('1231')).to eq(3)
        end
        it 'should return 2 if 2 exact and 2 number matches' do
          expect(game.number_match('1213')).to eq(2)
        end
      end
    end
    
    context '#reply_message' do
      before { game.start('2244') } 
      it 'should return "no matches" if no total matches' do
        expect(game.reply_message('5555')).to eq('no matches')
      end
      it 'should return "++--" if 2 exact and 2 number matches' do
        expect(game.reply_message('4242')).to eq('++--')
      end
    end  
          
      
      
      
    
  end
end
