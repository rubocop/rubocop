# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LeftJoin do
  subject(:cop) { described_class.new }

  context "when using .joins('LEFT JOIN ... ON ...')" do
    ['LEFT JOIN', 'left join'].each do |query|
      it 'registers an offense' do
        source = "User.joins('#{query} emails ON user.id = emails.user_id')"
        message = <<-RUBY.strip
          Use `.left_joins(:model)` instead of `.joins('left join ...')`.
        RUBY

        inspect_source(source)

        expect(cop.messages).to eq([message])
      end
    end
  end

  context "when using .joins('LEFT OUTER JOIN ... ON ...')" do
    ['LEFT OUTER JOIN', 'left outer join'].each do |query|
      it 'registers an offense' do
        source = "User.joins('#{query} emails ON user.id = emails.user_id')"
        message = <<-RUBY.strip
          Use `.left_outer_joins(:model)` instead of `.joins('left outer join ...')`.
        RUBY

        inspect_source(source)

        expect(cop.messages).to eq([message])
      end
    end
  end

  context "when not using .joins('LEFT JOIN ... ON ...')" do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        User.joins('RIGHT JOIN emails ON user.id = emails.user_id')
      RUBY
    end
  end

  context "when not using .joins('LEFT OUTER JOIN ... ON ...')" do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        User.joins('RIGHT OUTER JOIN emails ON user.id = emails.user_id')
      RUBY
    end
  end
end
