# frozen_string_literal: true

module RuboCop
  module Cop
    module Rails
      # This cop checks to see if any business logic is in a file where it is
      # not allowed. It helps to promote the pattern of Skinny Controllers,
      # Skinny Models by isolating business logic into business_models, lib
      # and other areas identified makes testing and reuse easier.
      # To resolve isolation, replace business logic with callbacks.
      #
      # Items considered business logic are:
      #   if, else, while, until, case, rescue, &&, ||, or regexp
      #
      # Note: In order to use with erb views, an additional gem like erb-lint
      # is required
      #
      # @example Controller Callback
      #   # bad
      #     class UserController < ApplicationController
      #       def show
      #         @user = UserLocator.find(params)
      #         if @user.valid?
      #           redirect_to users_home_path(@user.id)
      #         end
      #       end
      #     end
      #
      #     class UserLocator
      #       #...
      #       def valid?
      #         user
      #       end
      #     end
      #
      #   # good
      #     class UserController < ApplicationController
      #       def show
      #         @user = UserLocator.find(params)
      #         @user.valid do
      #           redirect_to users_home_path(@user.id)
      #         end
      #       end
      #     end
      #
      #     class UserLocator
      #       #...
      #       def valid
      #         yield if user
      #       end
      #     end
      #
      #
      # @example Controller Rescue
      #   # bad
      #     class MyController < ApplicationController
      #       def destroy
      #         @article = ArticleDestroyer.new
      #         begin
      #           @article.delete
      #           flash[:alert] = "Deleted Records"
      #           redirect_to action: 'index'
      #         rescue DestroyException => e
      #           flash[:error] = e.message
      #           redirect_to home_path(params[:id])
      #         end
      #       end
      #     end
      #
      #   # good
      #     class MyController < ApplicationController
      #       def destroy
      #         @article = ArticleDestroyer.new
      #         @article.delete
      #         @article.success do
      #           flash[:alert] = "Records Deleted"
      #           redirect_to action: 'index'
      #         end
      #         @article.failure do |error|
      #           flash[:error] = error
      #           redirect_to home_path(params[:id])
      #         end
      #       end
      #     end
      #
      #     class ArticleDestroyer
      #       def delete
      #         # (delete logic...)
      #       end
      #
      #       def success
      #         yield unless error
      #       end
      #
      #       def failure
      #         yield(error) if error
      #       end
      #     end
      #
      #   # good alternative with `yield self` in the delete method
      #     class MyController < ApplicationController
      #       def destroy
      #         @article = ArticleDestroyer.new
      #         @article.delete do |on|
      #           on.success do
      #             flash[:alert] = "Records Deleted"
      #             redirect_to action: 'index'
      #           end
      #
      #           on.failure do |error|
      #             flash[:error] = error
      #             redirect_to home_path(params[:id])
      #           end
      #         end
      #       end
      #     end
      #     class ArticleDestroyer
      #       def delete
      #         # (delete logic...)
      #         yield self
      #       end
      #
      #       def success
      #         yield unless error
      #       end
      #
      #       def failure
      #         yield(error) if error
      #       end
      #     end
      #
      class BusinessLogicNotAllowed < Cop
        MSG = 'Business logic is not allowed in this part of the application.'

        def on_business_method(node)
          add_offense(node)
        end

        alias on_if on_business_method
        alias on_case on_business_method
        alias on_resbody on_business_method
        alias on_ensure on_business_method
        alias defined on_business_method
        alias on_and on_business_method
        alias on_or on_business_method
        alias on_until on_business_method
        alias on_until_post on_business_method
        alias on_while on_business_method
        alias on_while_post on_business_method
        alias on_break on_business_method
        alias on_regexp on_business_method
      end
    end
  end
end
