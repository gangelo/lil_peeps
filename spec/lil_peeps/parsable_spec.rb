# frozen_string_literal: true

RSpec.describe LilPeeps::Parsable do
  let(:parsable) { class Klass; include LilPeeps::Parsable end }
  let(:subject) { parsable.new }
  let(:args) { [] }
  let(:option) { {} }

  before(:all) do
    described_class.send(:public, *described_class.protected_instance_methods)
  end

  describe '#find' do
    context 'with no option provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }
      let(:option_variants) { nil }

      it 'raises an error' do
        expect { subject.find(option_variants) }.to raise_error(ArgumentError, /is nil/)
      end
    end

    context 'with a single option variation provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }

      # No default arguments values provided
      context 'with no default argument values provided' do
        context 'when the option is found' do
          let(:option_variants) { '--test' }

          it 'returns the correct status, option and no value' do
            expect(subject.find(option_variants)).to eq([true, 'test'])
          end
        end

        context 'when the option is not found' do
          let(:option_variants) { '--not-found' }

          it 'returns the correct status, option and no value' do
            expect(subject.find(option_variants)).to eq([false, 'not-found'])
          end
        end
      end

      # One default argument values provided
      context 'with one default argument value provided' do
        context 'when the option is found' do
          let(:option_variants) { '--test' }

          it 'returns the correct status, option and value' do
            expect(subject.find(option_variants, :default)).to eq([true, 'test', :default])
          end
        end

        context 'when the option is not found' do
          let(:option_variants) { '--not-found' }

          it 'returns the correct status, option and value' do
            expect(subject.find(option_variants, :default)).to eq([false, 'not-found', :default])
          end
        end
      end

      # With multiple default argument values provided
      context 'with multiple default argument values provided' do
        context 'when no option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test) } }
          let(:option_variants) { '--test' }

          it 'returns the correct status, option and default values' do
            expect(subject.find(option_variants, [:default1, :default2])).to eq([true, 'test', :default1, :default2])
          end
        end

        context 'when one option argument is found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1) } }
          let(:option_variants) { '--test' }

          it 'returns the correct status, option, values and/or default values' do
            expect(subject.find(option_variants, [:default1, :default2])).to eq([true, 'test', '1', :default2])
          end
        end

        context 'when all option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1 2 3) } }
          let(:option_variants) { '--test' }

          it 'returns the correct status, option and values' do
            expect(subject.find(option_variants, [:default1, :default2, :default3])).to eq([true, 'test', '1', '2', '3'])
          end
        end
      end

      context 'with an option that has embedded dashes' do
        let(:subject) { parsable.new.tap { |o| o.args = %w(--embedded-with-dashes arg0) } }
        let(:option_variants) { '--embedded-with-dashes' }

        it 'returns the correct status, option and default values' do
          expect(subject.find(option_variants,
                              [:default1, :default2])).to eq([true, 'embedded-with-dashes', 'arg0', :default2])
        end
      end
    end

    context 'with multiple option variations are provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w(-d --debug --test -t -a --argh) } }

      # No default arguments values provided
      context 'with no default argument values provided' do
        context 'when the option is found' do
          let(:option_variants) { %w(--test -t) }

          it 'returns the correct status, option and no value' do
            expect(subject.find(option_variants)).to eq([true, 'test'])
          end
        end

        context 'when the option is not found' do
          let(:option_variants) { '--not-found' }

          it 'returns the correct status, option and no value' do
            expect(subject.find(option_variants)).to eq([false, 'not-found'])
          end
        end
      end

      # One default argument values provided
      context 'with one default argument value provided' do
        context 'when the option is found' do
          let(:option_variants) { %w(--test -t) }

          it 'returns the correct status, option and value' do
            expect(subject.find(option_variants, :default)).to eq([true, 'test', :default])
          end
        end

        context 'when the option is not found' do
          let(:option_variants) { '--not-found' }

          it 'returns the correct status, option and value' do
            expect(subject.find(option_variants, :default)).to eq([false, 'not-found', :default])
          end
        end
      end

      # With multiple default argument values provided
      context 'with multiple default argument values provided' do
        context 'when no option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(-t) } }
          let(:option_variants) { %w(--test -t) }

          it 'returns the correct status, option and default values' do
            expect(subject.find(option_variants, [:default1, :default2])).to eq([true, 't', :default1, :default2])
          end
        end

        context 'when one option argument is found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(--test 1) } }
          let(:option_variants) { %w(--test -t) }

          it 'returns the correct status, option, values and/or default values' do
            expect(subject.find(option_variants, [:default1, :default2])).to eq([true, 'test', '1', :default2])
          end
        end

        context 'when all option arguments are found' do
          let(:subject) { parsable.new.tap { |o| o.args = %w(-d --debug 1 2 3 -t 1 2 3 -a --argh) } }
          let(:option_variants) { %w(--test -t) }

          it 'returns the correct status, option and values' do
            expect(subject.find(option_variants, [:default1, :default2, :default3])).to eq([true, 't', '1', '2', '3'])
          end
        end
      end
    end

    context 'with options provided' do
      let(:subject) { parsable.new.tap { |o| o.args = %w($d $$debug $$test $t $a $$argh) } }
      let(:option_variants) { %w($$test $t) }

      context 'when an alternate option regex is provided' do
        it 'returns the correct status, option and no value' do
          subject.options = { option_regex: /(\A|\s)\$+/ }
          expect(subject.find(option_variants)).to eq([true, 'test'])
        end
      end
    end
  end
end
