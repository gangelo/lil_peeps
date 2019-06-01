# frozen_string_literal: true

RSpec.describe LilPeeps::Parser do
  let(:subject) { described_class.new(args, options) }
  let(:args) { [] }
  let(:options) { {} }

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe 'initialize' do
    it 'initializes the parser' do
      expect { subject }.not_to raise_error
    end

    context 'with correct parameters' do
      let(:args) { %w(--option1 1 2 3 --option2 a b c -d true) }
      let(:options) { { option_regex: /./ } }

      it 'sets the @args attribute' do
        expect(subject.args).to eq(args)
      end

      it 'sets the @option attribute' do
        expect(subject.options).to eq(options)
      end
    end
  end
end
