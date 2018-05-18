# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LeftJoin do
  subject(:cop) { described_class.new }

  context "when using .joins('LEFT JOIN ... ON ...')" do
    ['LEFT JOIN', 'left join'].each do |query|
      it 'registers an offense' do
        source = "User.joins('#{query} emails ON user.id = emails.user_id')"
        message = <<-RUBY.strip
          Use `.left_join(:emails)` instead of `.joins('#{query} emails ON user.id = emails.user_id')`.
        RUBY

        inspect_source(source)

        expect(cop.messages).to eq([message])
      end
    end
  end

  context "when not using .joins('LEFT JOIN ... ON ...')" do
    it 'does not register an offense' do
      source = "User.joins('RIGHT JOIN emails ON user.id = emails.user_id')"

      expect_no_offenses(source)
    end
  end
end
