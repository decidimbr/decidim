# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    def self.version
      "0.1.0"
    end

    def self.decidim_version
      [">= 0.29", "< 0.33"].freeze
    end
  end
end
