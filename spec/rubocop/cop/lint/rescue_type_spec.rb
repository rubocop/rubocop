# frozen_string_literal: true

describe RuboCop::Cop::Lint::RescueType do
  let(:config) { RuboCop::Config.new }
  subject(:cop) { described_class.new(config) }

  it 'accepts rescue modifier' do
    expect_no_offenses('foo rescue nil')
  end

  it 'accepts rescuing nothing' do
    expect_no_offenses(<<-RUBY)
      begin
        foo
      rescue
        bar
      end
    RUBY
  end

  it 'accepts rescuing a single exception' do
    expect_no_offenses(<<-RUBY)
      def foobar
        foo
      rescue NameError
        bar
      end
    RUBY
  end

  it 'accepts rescuing nothing' do
    expect_no_offenses(<<-RUBY)
     def foobar
        foo
      rescue
        bar
      end
    RUBY
  end

  shared_examples :offenses do |rescues|
    context 'begin rescue' do
      context "rescuing from #{rescues}" do
        let(:source) do
          <<-RUBY
            begin
              foo
            rescue #{rescues}
              bar
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue #{rescues}"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            begin
              foo
            rescue
              bar
            end
          RUBY
        end
      end

      context "rescuing from #{rescues} before another exception" do
        let(:source) do
          <<-RUBY
            begin
              foo
            rescue #{rescues}, StandardError
              bar
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue #{rescues}, StandardError"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY
        end
      end

      context "rescuing from #{rescues} after another exception" do
        let(:source) do
          <<-RUBY
            begin
              foo
            rescue StandardError, #{rescues}
              bar
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue StandardError, #{rescues}"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            begin
              foo
            rescue StandardError
              bar
            end
          RUBY
        end
      end
    end

    context 'begin rescue ensure' do
      context "rescuing from #{rescues}" do
        let(:source) do
          <<-RUBY
            begin
              foo
            rescue #{rescues}
              bar
            ensure
              baz
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue #{rescues}"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            begin
              foo
            rescue
              bar
            ensure
              baz
            end
          RUBY
        end
      end
    end

    context 'def rescue' do
      context "rescuing from #{rescues}" do
        let(:source) do
          <<-RUBY
            def foobar
              foo
            rescue #{rescues}
              bar
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue #{rescues}"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            def foobar
              foo
            rescue
              bar
            end
          RUBY
        end
      end
    end

    context 'def rescue ensure' do
      context "rescuing from #{rescues}" do
        let(:source) do
          <<-RUBY
            def foobar
              foo
            rescue #{rescues}
              bar
            ensure
              baz
            end
          RUBY
        end

        it 'registers an offense' do
          inspect_source(source)

          expect(cop.highlights).to eq(["rescue #{rescues}"])
          expect(cop.messages)
            .to eq(["Rescuing from `#{rescues}` will raise a `TypeError` " \
                    'instead of catching the actual exception.'])
        end

        it 'auto-corrects' do
          new_source = autocorrect_source(cop, source)

          expect(new_source).to eq(<<-RUBY)
            def foobar
              foo
            rescue
              bar
            ensure
              baz
            end
          RUBY
        end
      end
    end
  end

  it_behaves_like :offenses, 'nil'
  it_behaves_like :offenses, "'string'"
  it_behaves_like :offenses, '"#{string}"'
  it_behaves_like :offenses, '0'
  it_behaves_like :offenses, '0.0'
  it_behaves_like :offenses, '[]'
  it_behaves_like :offenses, '{}'
  it_behaves_like :offenses, ':symbol'
end
