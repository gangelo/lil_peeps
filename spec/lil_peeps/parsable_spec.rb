# frozen_string_literal: true

RSpec.describe LilPeeps::Parsable do
  let(:parsable) { class Klass; include LilPeeps::Parsable end }
  let(:subject) { parsable.new }
  let(:args) { [] }
  let(:option) { {} }

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe '#args' do
    let(:args) { %w(--arg) }
    it 'gets the attribute' do
      subject.args = args
      expect(subject.args).to eq(args)
    end
  end

  describe '#args=' do
    let(:args) { %w(--arg) }
    it 'sets the attribute' do
      subject.args = args
      expect(subject.args).to eq(args)
    end
  end

  describe '#clean!' do
    let(:subject) { parsable.new }

    context 'when passing an empty array' do
      it 'returns an empty array' do
        expect(subject.clean!(args)).to eq([])
      end
    end

    context 'when passing option and parameters' do
      let(:args) { %w(keep1 --arg1 keep2 -arg2 --arg3 keep3 -arg4) }
      it 'removes unwanted entries' do
        expect(subject.clean!(args)).to eq(%w(keep1 keep2 keep3))
      end
    end

    context 'when passing only option' do
      let(:args) { %w(keep1 keep2 keep3) }
      it 'returns the option' do
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

  describe '#ensure_array' do
    let(:subject) { parsable.new }
    context 'when an Array is passed' do
      it 'returns an Array' do
        expect(subject.ensure_array([1, 2, 3])).to eq([1, 2, 3])
      end
    end

    context 'when an Array is NOT passed' do
      it 'returns an Array' do
        expect(subject.ensure_array(1)).to eq([1])
      end
    end

    context 'when an empty Array is passed' do
      it 'returns an empty Array' do
        expect(subject.ensure_array([])).to eq([])
      end
    end

    context 'when nil is passed' do
      it 'returns an empty Array' do
        expect(subject.ensure_array(nil)).to eq([])
      end
    end
  end

  describe '#find' do
    context 'with no option provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }

      it 'raises an error' do
        expect { subject.find(nil) }.to raise_error(ArgumentError, /is nil/)
      end
    end

    context 'with a single option variation provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }

      # No default arguments values provided
      context 'with no default argument values provided' do
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

      # One default argument values provided
      context 'with one default argument value provided' do
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

      # With multiple default argument values provided
      context 'with multiple default argument values provided' do
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

    context 'with multiple option variations are provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(-d --debug --test -t -a --argh) } }

      # No default arguments values provided
      context 'with no default argument values provided' do
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

      # One default argument values provided
      context 'with one default argument value provided' do
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

      # With multiple default argument values provided
      context 'with multiple default argument values provided' do
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

  describe '#option' do
    let(:subject) { parsable.new }
    let(:options) { { option: :option } }
    it 'gets the attribute' do
      subject.options = options
      expect(subject.options).to eq(options)
    end
  end

  describe '#option=' do
    let(:subject) { parsable.new }
    let(:options) { { option: :option } }

    context 'when a Hash is passed' do
      it 'sets the attribute' do
        subject.options = options
        expect(subject.options).to eq(options)
      end
    end

    context 'when an incorrect value is passed' do
      context 'when nil' do
        it 'raise an error' do
          expect { subject.options = nil }.to raise_error(ArgumentError, /is nil/)
        end
      end

      context 'when not a Hash' do
        it 'raises an error' do
          expect { subject.options = :bad }.to raise_error(ArgumentError, /not a Hash/)
        end
      end
    end
  end

  describe '#option?' do
    let(:subject) { parsable.new }
    context 'when passing an option' do
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

  describe '#option_found' do
    let(:subject) { parsable.new }

    context 'when passed correct arguments' do
      let(:command_line_args) { %w(-t) }
      let(:option) { %w(--test -t) }
      let(:option_indicies) { subject.select_option_indicies(option, command_line_args) }
      let(:argument_defaults) { %w(default) }

      before do
        subject.args = command_line_args
      end

      context 'when argument_defaults is not an Array' do
        it 'returns the correct values' do
          expect(subject.option_found(option_indicies, argument_defaults)).to eq([true, '-t', 'default'])
        end
      end

      context 'when argument_defaults is an empty Array' do
        it 'returns the correct values' do
          expect(subject.option_found(option_indicies, [])).to eq([true, '-t'])
        end
      end

      context 'when argument_defaults is an Array with one argument default' do
        it 'returns the correct values' do
          expect(subject.option_found(option_indicies, %w(default))).to eq([true, '-t', 'default'])
        end
      end

      context 'when argument_defaults is an Array with multiple argument defaults' do
        it 'returns the correct values' do
          expect(subject.option_found(option_indicies, %w(default1 default2))).to eq([true, '-t', 'default1', 'default2'])
        end
      end
    end

    context 'when passed incorrect arguments' do
      context 'when option is nil' do
        it 'raises an error' do
          expect { subject.option_found(nil, 'default') }.to raise_error(ArgumentError, /is nil/)
        end
      end

      context 'when option is not an Array' do
        it 'raises an error' do
          expect { subject.option_found(:no_good, 'default') }.to raise_error(ArgumentError, /is not an Array/)
        end
      end

      context 'when argument_defaults is nil' do
        it 'raises an error' do
          expect { subject.option_found(%w(--test), nil) }.to raise_error(ArgumentError, /is nil/)
        end
      end
    end

    context 'when no &block is passed' do
      let(:command_line_args) { %w(-t) }
      let(:option) { %w(--test -t) }
      let(:option_indicies) { subject.select_option_indicies(option, command_line_args) }
      let(:argument_defaults) { %w(default) }

      before do
        subject.args = command_line_args
      end

      it 'should not raise an error' do
        expect { subject.option_found(option_indicies, argument_defaults) }.to_not raise_error
      end
    end
  end

  describe '#option_not_found' do
    let(:subject) { parsable.new }
    context 'when passed correct arguments' do
      context 'when argument_defaults is not an Array' do
        it 'returns the correct values' do
          expect(subject.option_not_found(%w(--test -t), 'default')).to eq([false, '-t', 'default'])
        end
      end

      context 'when argument_defaults is an empty Array' do
        it 'returns the correct values' do
          expect(subject.option_not_found(%w(--test -t), [])).to eq([false, '-t'])
        end
      end

      context 'when argument_defaults is an Array with one argument default' do
        it 'returns the correct values' do
          expect(subject.option_not_found(%w(--test -t), %w(default))).to eq([false, '-t', 'default'])
        end
      end

      context 'when argument_defaults is an Array with multiple argument defaults' do
        it 'returns the correct values' do
          expect(subject.option_not_found(%w(--test -t), %w(default1 default2))).to eq([false, '-t', 'default1', 'default2'])
        end
      end
    end

    context 'when passed incorrect arguments' do
      context 'when option is nil' do
        it 'raises an error' do
          expect { subject.option_not_found(nil, 'default') }.to raise_error(ArgumentError, /is nil/)
        end
      end

      context 'when option is not an Array' do
        it 'raises an error' do
          expect { subject.option_not_found(:no_good, 'default') }.to raise_error(ArgumentError, /is not an Array/)
        end
      end

      context 'when argument_defaults is nil' do
        it 'raises an error' do
          expect { subject.option_not_found(%w(--test), nil) }.to raise_error(ArgumentError, /is nil/)
        end
      end
    end

    context 'when no &block is passed' do
      it 'should not raise an error' do
        expect { subject.option_not_found(%w(--test -t), 'default') }.to_not raise_error
      end
    end
  end

  describe '#return_results' do
    context 'when valid arguments are passed' do
    end

    context 'when invalid arguments are passed' do
      context 'option_found' do
        context 'when nil' do
          it 'raises an error'
        end
        context 'when not a boolean' do
          it 'raises an error'
        end
      end

      context 'option' do
      end

      context '*values' do
      end
    end
  end

end
