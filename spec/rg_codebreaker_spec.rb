require 'spec_helper'

module RgCodebreaker
  describe Game do
    subject { game.instance_variable_get(:@secret_code) }
    context '#start' do
      let(:game) { Game.new }

      before do
        game.start
        @init_code = game.instance_variable_get(:@secret_code)
      end

      it 'saves secret code' do
        expect(subject).not_to be_empty
      end

      it "saves 4 numbers secret code" do
        expect(subject).to have(4).items
      end

      it 'saves secret code with numbers from 1 to 6' do
        expect(subject).to match(/[1-6]{4}/)
      end
      
      context 'while each time game starts' do
        let!(:go) { game.start }
        it 'generates unique code that not equal to previous' do
          expect(subject).not_to eq(@init_code)
        end
      end
      
      
    end
  end
end
