# frozen_string_literal: true

require 'rubocop/cop/naming/method_name_get_prefix'
require 'spec_helper'

RSpec.describe RuboCop::Cop::Naming::MethodNameGetPrefix, :config do
  let(:id) { 1 }

  context 'when method has get_ prefix with arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id)
        ^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end

    it 'autocorrects to _for pattern' do
      new_source = autocorrect_source(<<~RUBY)
        def get_user(id)
          User.find(id)
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def user_for(id)
          User.find(id)
        end
      RUBY
    end
  end

  context 'when method has get_ prefix without arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def get_user
          @user
        end
      RUBY
    end
  end

  context 'when method makes HTTP GET requests' do
    it 'does not register an offense for connection.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          connection.get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for HTTP.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          HTTP.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for Net::HTTP::Get.new' do
      expect_no_offenses(<<~RUBY)
        def get_checkout(id)
          request = Net::HTTP::Get.new(uri)
          http.request(request)
        end
      RUBY
    end

    it 'does not register an offense for http.request' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          request = Net::HTTP::Get.new(uri)
          https.request(request)
        end
      RUBY
    end

    it 'does not register an offense for RestClient.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          RestClient.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for Faraday.get' do
      expect_no_offenses(<<~RUBY)
        def get_user(id)
          Faraday.get("https://api.example.com/users/#{id}")
        end
      RUBY
    end
  end

  context 'when method is in API client file and calls get()' do
    it 'does not register an offense for client file' do
      expect_no_offenses(<<~RUBY, 'app/clients/user_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for api_client file' do
      expect_no_offenses(<<~RUBY, 'lib/api_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for controller file' do
      expect_no_offenses(<<~RUBY, 'app/controllers/users_controller.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for file in /api/ directory' do
      expect_no_offenses(<<~RUBY, 'app/api/v1/users.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end

    it 'does not register an offense for file in /clients/ directory' do
      expect_no_offenses(<<~RUBY, 'lib/clients/sendbird_client.rb')
        def get_user(id)
          get("/users/#{id}")
        end
      RUBY
    end
  end

  context 'when method has multiple arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_db_line_item(order_id, line_item_id)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `db_line_item_for` or `find_db_line_item` instead.
        end
      RUBY
    end

    it 'autocorrects correctly' do
      new_source = autocorrect_source(<<~RUBY)
        def get_db_line_item(order_id, line_item_id)
          # implementation
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def db_line_item_for(order_id, line_item_id)
          # implementation
        end
      RUBY
    end
  end

  context 'when method has keyword arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id:, name:)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end
  end

  context 'when method has block argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def get_user(id, &block)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
        end
      RUBY
    end
  end

  context 'edge cases' do
    it 'handles nested method definitions' do
      expect_offense(<<~RUBY)
        class UserService
          def get_user(id)
          ^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.
            def helper_method
            end
          end
        end
      RUBY
    end

    it 'handles methods with complex bodies' do
      expect_offense(<<~RUBY)
        def get_user(id)
        ^^^^^^^^^^^^^^^^ Avoid using `get_` prefix for methods with arguments. Consider using `user_for` or `find_user` instead.

          return nil if id.nil?
          User.find_by(id: id) || User.create(id: id)
        end
      RUBY
    end
  end

  context 'when method has set_ prefix with arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def set_custom_local_var(val)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `custom_local_var=` instead.
        end
      RUBY
    end

    it 'autocorrects to = method syntax' do
      new_source = autocorrect_source(<<~RUBY)
        def set_custom_local_var(val)
          @custom_local_var = val
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def custom_local_var=(val)
          @custom_local_var = val
        end
      RUBY
    end

    it 'does not register an offense for methods with 2+ required arguments' do
      expect_no_offenses(<<~RUBY)
        def set_user(id, name)
          @user = User.new(id: id, name: name)
        end
      RUBY
    end
  end

  context 'when method has set_ prefix without arguments' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def set_user
          @user
        end
      RUBY
    end
  end

  context 'when set_ method is in API client file' do
    it 'does not register an offense for methods with 2+ required arguments' do
      expect_no_offenses(<<~RUBY, 'app/clients/user_client.rb')
        def set_user(id, data)
          post("/users/#{id}", data)
        end
      RUBY
    end

    it 'registers an offense for single-argument method in client file' do
      expect_offense(<<~RUBY, 'app/clients/user_client.rb')
        def set_configuration(value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `create_configuration`, `put_configuration`, `update_configuration` instead.
        end
      RUBY
    end

    it 'autocorrects to create_ prefix for single-argument method in client file' do
      new_source = autocorrect_source(<<~RUBY, 'app/clients/user_client.rb')
        def set_configuration(value)
          post("/config", value)
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def create_configuration(value)
          post("/config", value)
        end
      RUBY
    end

    it 'registers an offense for api_client file' do
      expect_offense(<<~RUBY, 'lib/api_client.rb')
        def set_configuration(value)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `create_configuration`, `put_configuration`, `update_configuration` instead.
        end
      RUBY
    end

    it 'registers an offense for controller file' do
      expect_offense(<<~RUBY, 'app/controllers/users_controller.rb')
        def set_user_preferences(prefs)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `create_user_preferences`, `put_user_preferences`, `update_user_preferences` instead.
        end
      RUBY
    end

    it 'registers an offense for file in /api/ directory' do
      expect_offense(<<~RUBY, 'app/api/v1/users.rb')
        def set_user_data(data)
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `create_user_data`, `put_user_data`, `update_user_data` instead.
        end
      RUBY
    end

    it 'registers an offense for file in /clients/ directory' do
      expect_offense(<<~RUBY, 'lib/clients/sendbird_client.rb')
        def set_channel_settings(settings)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `create_channel_settings`, `put_channel_settings`, `update_channel_settings` instead.
        end
      RUBY
    end

    it 'autocorrects to create_ prefix for API file' do
      new_source = autocorrect_source(<<~RUBY, 'app/api/v1/users.rb')
        def set_user_data(data)
          put("/users", data)
        end
      RUBY

      expect(new_source).to eq(<<~RUBY)
        def create_user_data(data)
          put("/users", data)
        end
      RUBY
    end
  end

  context 'when set_ method has multiple arguments' do
    it 'does not register an offense for 2+ required arguments' do
      expect_no_offenses(<<~RUBY)
        def set_db_line_item(order_id, line_item_id, value)
          # implementation
        end
      RUBY
    end
  end

  context 'when set_ method has keyword arguments' do
    it 'does not register an offense for 2+ required keyword arguments' do
      expect_no_offenses(<<~RUBY)
        def set_user(id:, name:)
          @user = User.new(id: id, name: name)
        end
      RUBY
    end

    it 'registers an offense for single required keyword argument' do
      expect_offense(<<~RUBY)
        def set_user(id:)
        ^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.
        end
      RUBY
    end

    it 'registers an offense for single positional and optional keyword arguments' do
      expect_offense(<<~RUBY)
        def set_user(id, name: 'default')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.
        end
      RUBY
    end
  end

  context 'when set_ method has block argument' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        def set_user(id, &block)
        ^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.
        end
      RUBY
    end
  end

  context 'set_ prefix edge cases' do
    it 'handles nested method definitions' do
      expect_offense(<<~RUBY)
        class UserService
          def set_user(id)
          ^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.
            def helper_method
            end
          end
        end
      RUBY
    end

    it 'handles methods with complex bodies' do
      expect_offense(<<~RUBY)
        def set_user(id)
        ^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.

          return nil if id.nil?
          @user = User.find_by(id: id) || User.create(id: id)
        end
      RUBY
    end

    it 'handles set_ methods that make HTTP calls (still flags them)' do
      expect_offense(<<~RUBY)
        def set_user(id)
        ^^^^^^^^^^^^^^^^ Avoid using `set_` prefix for methods with arguments. Consider using `user=` instead.
          connection.post("/users/#{id}")
        end
      RUBY
    end
  end
end
