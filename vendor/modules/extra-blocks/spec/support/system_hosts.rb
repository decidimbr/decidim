# frozen_string_literal: true

# Rails 7 HostAuthorization blocks Capybara hosts (N.lvh.me:port) in system specs.
# Middleware stack is frozen after boot, so we stub #call for the test process.
module Decidim
  module ExtraBlocks
    module HostAuthorizationBypass
      def call(env)
        @app.call(env)
      end
    end
  end
end

ActionDispatch::HostAuthorization.prepend(Decidim::ExtraBlocks::HostAuthorizationBypass)
