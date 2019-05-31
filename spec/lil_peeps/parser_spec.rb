# frozen_string_literal: true

RSpec.describe LilPeeps::Parser do
  let(:parser) { described_class.new(args, option) }
  let(:args) { [] }
  let(:option) { {} }

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe 'initialize' do
    it 'initializes the parser' do
      expect { parser }.not_to raise_error
    end

    it 'sets the @args attribute' do
    end

    it 'sets the @option attribute'
  end
end
