# frozen_string_literal: true

RSpec.describe RuboCop::Cop::InternalAffairs::StyleDetectedApiUse, :config do
  it 'registers an offense when correct_style_detected is used without a negative *_style_detected follow up' do
    expect_offense(<<~RUBY)
      def on_send(node)
      ^{} `correct_style_detected` method called without calling a negative `*_style_detected` method.
        if offense?
          add_offense(node)
        else
          correct_style_detected
        end
      end
    RUBY
  end

  it 'registers an offense when correct_style_detected is used in a conditional expression' do
    expect_offense(<<~RUBY)
      def on_send(node)
        return if correct_style_detected
                  ^^^^^^^^^^^^^^^^^^^^^^ `*_style_detected` method called in conditional.

        add_offense(node)
        opposite_style_detected
      end
    RUBY
  end

  %i[opposite_style_detected unexpected_style_detected
     ambiguous_style_detected conflicting_styles_detected
     unrecognized_style_detected
     no_acceptable_style!].each do |negative_style_detected_method|
    it "registers an offense when #{negative_style_detected_method} is used in a conditional expression" do
      expect_offense(<<~RUBY)
        def on_send(node)
          return add_offense(node) if #{negative_style_detected_method}
                                      #{'^' * negative_style_detected_method.to_s.length} `*_style_detected` method called in conditional.
          correct_style_detected
        end
      RUBY
    end

    it "registers an offense when #{negative_style_detected_method} is used without a correct_style_detected follow up" do
      expect_offense(<<~RUBY)
        def on_send(node)
        ^{} negative `*_style_detected` methods called without calling `correct_style_detected` method.
          return unless offense?

          add_offense(node)
          #{negative_style_detected_method}
        end
      RUBY
    end

    it "does not register an offense when correct_style_detected and a #{negative_style_detected_method} are both used" do
      expect_no_offenses(<<~RUBY)
        def on_send(node)
          if offense?
            add_offense(node)
            #{negative_style_detected_method}
          else
            correct_style_detected
          end
        end
      RUBY
    end
  end
end
