# frozen_string_literal: true

RSpec.describe LilPeeps::Parser do
  let(:parser) { described_class.new(args, option) }
  let(:args) { [] }
  let(:option) { {} }

  describe 'initialize' do
    it 'initializes the parser' do
      expect { parser }.not_to raise_error
    end

    it 'sets the @args attribute'
    it 'sets the @option attribute'
  end
end
