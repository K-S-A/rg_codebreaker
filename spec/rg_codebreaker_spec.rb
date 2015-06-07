require 'spec_helper'

module RgCodebreaker
  describe Game do
    before { allow(File).to receive(:open).and_return({}) }
    let(:game) { Game.new.start('1234') }
    let(:code) { game.send(:generate_code) }
    test_cases = [[0, 0, 0, "1122", "3344", "no matches"], [1, 1, 0, "1122", "1333", "+"], [1, 0, 1, "1122", "3331", "-"],\
                  [2, 2, 0, "1122", "3123", "++"], [2, 1, 1, "1122", "2133", "+-"], [2, 0, 2, "1122", "3213", "--"],\
                  [3, 3, 0, "1122", "1322", "+++"], [3, 2, 1, "1122", "2123", "++-"], [3, 1, 2, "1122", "2221", "+--"],\
                  [3, 0, 3, "1122", "2213", "---"], [4, 4, 0, "1122", "1122", "++++"], [4, 2, 2, "1122", "2121", "++--"],\
                  [4, 1, 3, "1123", "1312", "+---"], [4, 0, 4, "1122", "2211", "----"]]
                  # [total_num, exact_num, number_num, @secret_code, guess, reply_message]

    context '#start' do
      it 'should set secret code' do
        expect(game.instance_variable_get(:@secret_code)).to eq('1234')
      end
      it 'should set the maximum number of attempts equal to 8' do
        expect(game.instance_variable_get(:@attempts)).to eq(8)
      end
      it "should return RgCodebreaker::Game object" do
        expect(game.start).to be_kind_of(RgCodebreaker::Game)
      end
      it 'should set instance variable @hint to nil' do
        expect(game.instance_variable_get(:@hint)).to be_nil
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
      it 'should return random number of secret code' do
        expect(game.instance_variable_get(:@secret_code)).to include(game.send(:hint))
      end
      it 'should be used only one time' do
        game.send(:hint)
        expect(game.send(:hint)).to be_nil
      end
    end

    context '#attempts' do
      it 'should return number of maximum attempts' do
        expect(game.attempts).to eq(8)
      end
    end

    context '#use_attempt' do
      it 'should decrease number of attempts by 1' do
        expect{ 3.times{ game.send(:use_attempt) } }.to change { game.attempts }.by(-3)
      end
    end

    context '#compare' do
      it 'should return "invalid" if guess have wrong format' do
        expect(game.compare('94j2')).to eq('invalid')
      end
      it 'should call hint if received "hint"' do
        allow(game).to receive(:hint).and_return("1").once
        expect(game.compare('hint')).to eq('1')
      end
      it "should return array with secret code and '++++' if code is broken within allowable number of attempts" do
        expect(game.compare("1234")).to eq(['1234','++++'])
      end
      it "should return array with guess and compared '+' and '-' signs if code is not broken and some attempts left" do
        expect(game.compare("1243")).to eq(['1243', '++--'])
      end
    end

    context '#save' do
      it 'should call #open with arguments ""statistics.rb", "w", 510"' do
        expect(File).to receive(:open).with('statistics.rb', 'w', 510).once
        game.save('Player')
      end
    end

    context '#statistics' do
      it 'should return saved statistics' do
        allow(File).to receive(:exist?).and_return(true)
        game.save('Player')
        expect(game.statistics).to include('Player')
      end
      it 'should return "nil" if no statistic data' do
        expect(game.statistics).to be_nil
      end
    end

  end
end
