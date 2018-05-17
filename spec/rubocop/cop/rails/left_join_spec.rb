# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::LeftJoin do
  subject(:cop) { described_class.new }

  context 'when using .joins("left join ...")' do
    ['LEFT JOIN', 'left join'].each do |join_query|
      it 'registers an offense' do
        inspect_source("User.joins('#{join_query} emails ON user.id = emails.user_id')")

        expect(cop.messages).to eq(["Use `.left_join(:emails)` instead of `.joins('#{join_query} emails ON user.id = emails.user_id')`."])
      end
    end
  end

  context 'when not using .joins("left join ...")' do
    it 'does not register an offense' do
      expect_no_offenses("User.joins('RIGHT JOIN emails ON user.id = emails.user_id')")
    end
  end
end
