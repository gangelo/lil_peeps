# frozen_string_literal: true

RSpec.describe LilPeeps::Parsable do
  let(:parsable) { class Klass; include LilPeeps::Parsable end }
  let(:args) { [] }
  let(:options) { {} }

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe 'initialize' do
    it 'initializes the parser' do
      expect { parsable }.not_to raise_error
    end
  end

  describe 'args' do
    let(:subject) { parsable.new }
    let(:args) { %w(--arg) }
    it 'gets/sets the attribute' do
      subject.args = args
      expect(subject.args).to eq(args)
    end
  end

  describe 'clean!' do
    let(:subject) { parsable.new }

    context 'when passing an empty array' do
      it 'returns an empty array' do
        expect(subject.clean!(args)).to eq([])
      end
    end

    context 'when passing options and parameters' do
      let(:args) { %w(keep1 --arg1 keep2 -arg2 --arg3 keep3 -arg4) }
      it 'removes unwanted entries' do
        expect(subject.clean!(args)).to eq(%w(keep1 keep2 keep3))
      end
    end

    context 'when passing only options' do
      let(:args) { %w(keep1 keep2 keep3) }
      it 'returns the options' do
        expect(subject.clean!(args)).to eq(args)
      end
    end

    context 'when passing only parameters' do
      let(:args) { %w(--arg1 -arg2 --arg3 -arg4) }
      it 'returns an empty array' do
        expect(subject.clean!(args)).to eq([])
      end
    end
  end

  describe 'find' do
    context 'with a single option variation' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }

      # No option arguments
      context 'with no option arguments' do
        context 'when the option is found' do
          it 'returns the correct status, option and no value' do
            expect(subject.find('--test')).to eq([true, '--test'])
          end
        end

        context 'when the option is not found' do
          it 'returns the correct status, option and no value' do
            expect(subject.find('--not-found')).to eq([false, '--not-found'])
          end
        end
      end

      # One option argument
      context 'with one option argument' do
        context 'when the option is found' do
          it 'returns the correct status, option and value' do
            expect(subject.find('--test', :default)).to eq([true, '--test', :default])
          end
        end

        context 'when the option is not found' do
          it 'returns the correct status, option and value' do
            expect(subject.find('--not-found', :default)).to eq([false, '--not-found', :default])
          end
        end
      end

      # Multiple option arguments
      context 'with multiple option arguments' do
        context 'when no option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }
          it 'returns the correct status, option and default values' do
            expect(subject.find('--test', [:default1, :default2])).to eq([true, '--test', :default1, :default2])
          end
        end

        context 'when one option argument is found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1) } }
          it 'returns the correct status, option, values and/or default values' do
            expect(subject.find('--test', [:default1, :default2])).to eq([true, '--test', '1', :default2])
          end
        end

        context 'when all option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1 2 3) } }
          it 'returns the correct status, option and values' do
            expect(subject.find('--test', [:default1, :default2, :default3])).to eq([true, '--test', '1', '2', '3'])
          end
        end
      end
    end

    context 'with multiple option variations' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(-d --debug --test -t -a --argh) } }

      # No option arguments
      context 'with no option arguments' do
        context 'when the option is found' do
          it 'returns the correct status, option and no value' do
            expect(subject.find(%w(--test -t))).to eq([true, '-t'])
          end
        end

        context 'when the option is not found' do
          it 'returns the correct status, option and no value' do
            expect(subject.find('--not-found')).to eq([false, '--not-found'])
          end
        end
      end

      # One option argument
      context 'with one option argument' do
        context 'when the option is found' do
          it 'returns the correct status, option and value' do
            expect(subject.find(%w(--test -t), :default)).to eq([true, '-t', :default])
          end
        end

        context 'when the option is not found' do
          it 'returns the correct status, option and value' do
            expect(subject.find('--not-found', :default)).to eq([false, '--not-found', :default])
          end
        end
      end

      # Multiple option arguments
      context 'with multiple option arguments' do
        context 'when no option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(-t) } }
          it 'returns the correct status, option and default values' do
            expect(subject.find(%w(-t --test), [:default1, :default2])).to eq([true, '-t', :default1, :default2])
          end
        end

        context 'when one option argument is found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1) } }
          it 'returns the correct status, option, values and/or default values' do
            expect(subject.find(%w(--test -t), [:default1, :default2])).to eq([true, '--test', '1', :default2])
          end
        end

        context 'when all option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(-d --debug 1 2 3 -t 1 2 3 -a --argh) } }
          it 'returns the correct status, option and values' do
            expect(subject.find(%w(--test -t), [:default1, :default2, :default3])).to eq([true, '-t', '1', '2', '3'])
          end
        end
      end
    end
  end

  describe 'option?' do
    let(:subject) { parsable.new }
    context 'when passing a option' do
      it 'returns true' do
        expect(subject.option?('-option')).to be_truthy
        expect(subject.option?('--option')).to be_truthy
      end
    end

    context 'when passing a non-option' do
      it 'returns true' do
        expect(subject.option?('non-option')).to be_falsy
      end
    end
  end

  describe 'options' do
    let(:subject) { parsable.new }
    let(:options) { { option: :option } }
    it 'gets/sets the attribute' do
      subject.options = options
      expect(subject.options).to eq(options)
    end
  end
end
