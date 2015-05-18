require 'spec_helper'

module RgCodebreaker
  describe Game do
  
    let(:out) { double("out").as_null_object }
    let(:game) { Game.new(out) }
    let(:start) { game.start }
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
      xit 'should test gets' do
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
        
    context '#validate' do
      context 'should output if guess code' do
        before { expect(out).to receive(:puts).with("Code must contain 4 digits from 1 to 6.").once }
        it 'longer than expected' do
          game.validate("12345")
        end
        it 'shorter than expected' do
          game.validate("123")
        end
        it 'have not only numbers' do
          game.validate("123d")
        end
        it 'have numbers outside range 1..6' do
          game.validate("7980")
        end
      end
      context 'when guess code is valid' do
        it 'should not output' do
          expect(out).not_to receive(:puts)
          game.validate("1234")
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
        before { game.start('1234') } 
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
  end
end
