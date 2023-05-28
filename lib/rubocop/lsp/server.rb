require "language_server-protocol"
require_relative "standardizer"
require_relative "routes"
require_relative "logger"

#
# This code is based on https://github.com/standardrb/standard.
#
# Copyright (c) 2023 Test Double, Inc.
#
# The MIT License (MIT)
#
# https://github.com/standardrb/standard/blob/main/LICENSE.txt
#
module Standard
  module Lsp
    Proto = LanguageServer::Protocol
    SEV = Proto::Constant::DiagnosticSeverity

    class Server
      def initialize(config)
        @writer = Proto::Transport::Io::Writer.new($stdout)
        @reader = Proto::Transport::Io::Reader.new($stdin)
        @logger = Logger.new
        @standardizer = Standard::Lsp::Standardizer.new(config, @logger)
        @routes = Routes.new(@writer, @logger, @standardizer)
      end

      def start
        @reader.read do |request|
          if !request.key?(:method)
            @routes.handle_method_missing(request)
          elsif (route = @routes.for(request[:method]))
            route.call(request)
          else
            @routes.handle_unsupported_method(request)
          end
        rescue => e
          @logger.puts "Error #{e.class} #{e.message[0..100]}"
          @logger.puts e.backtrace.inspect
        end
      end
    end
  end
end
