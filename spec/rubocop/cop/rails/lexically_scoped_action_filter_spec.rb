# frozen_string_literal: true

describe RuboCop::Cop::Rails::LexicallyScopedActionFilter do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when string node method is not defined' do
    expect_offense <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, except: 'health_check'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `health_check` is not explicitly defined on the controller.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when symbol node method is not defined' do
    expect_offense <<-RUBY
      class LoginController < ApplicationController
        skip_before_action :require_login, only: :health_check
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `health_check` is not explicitly defined on the controller.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when array string node methods are not defined' do
    expect_offense <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %w[index settings]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `settings` is not explicitly defined on the controller.

        def index
        end
      end
    RUBY
  end

  it 'registers an offense when array symbol node methods are not defined' do
    expect_offense <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %i[index settings logout]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `settings`, `logout` are not explicitly defined on the controller.

        def index
        end
      end
    RUBY
  end

  it "doesn't register an offense when string node method is defined" do
    expect_no_offenses <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, except: 'health_check'

        def health_check
        end
      end
    RUBY
  end

  it "doesn't register an offense when symbol node method is defined" do
    expect_no_offenses <<-RUBY
      class LoginController < ApplicationController
        skip_before_action :require_login, only: :health_check

        def health_check
        end
      end
    RUBY
  end

  it "doesn't register an offense when array string node methods are defined" do
    expect_no_offenses <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %w[index settings]

        def index
        end

        def settings
        end
      end
    RUBY
  end

  it "doesn't register an offense when array symbol node methods are defined" do
    expect_no_offenses <<-RUBY
      class LoginController < ApplicationController
        before_action :require_login, only: %i[index settings logout]

        def index
        end

        def settings
        end

        def logout
        end
      end
    RUBY
  end
end
