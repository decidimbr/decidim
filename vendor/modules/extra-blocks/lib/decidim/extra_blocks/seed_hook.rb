# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    # Runs Extra Blocks QA seeds after the full Decidim.seed! pipeline.
    # ponytail: prepend until Decidim exposes an official post-seed hook
    module SeedHook
      def seed!
        Decidim::ExtraBlocks::FakerCompat.ensure_twitter!
        super
        Decidim::ExtraBlocks::Seeds.new.call
      end
    end

    # Faker 3.x dropped Twitter; Decidim 0.29 core/system seeds still call it.
    # ponytail: shim only for seed; remove when Decidim stops using Faker::Twitter
    module FakerCompat
      module_function

      def ensure_twitter!
        require "faker"
        return if defined?(::Faker::Twitter)

        ::Faker.const_set(:Twitter, Class.new do
          def self.unique
            self
          end

          def self.screen_name
            "seed#{SecureRandom.hex(3)}"
          end
        end)
      end
    end
  end
end
