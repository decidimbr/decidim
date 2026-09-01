# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe "max_cache" do
      around do |example|
        previous = ENV.fetch("EXTRA_BLOCK_MAX_CACHE", nil)
        example.run
      ensure
        if previous.nil?
          ENV.delete("EXTRA_BLOCK_MAX_CACHE")
        else
          ENV["EXTRA_BLOCK_MAX_CACHE"] = previous
        end
      end

      it "defaults to 60 minutes" do
        ENV.delete("EXTRA_BLOCK_MAX_CACHE")
        expect(Decidim::ExtraBlocks.max_cache).to eq(60.minutes)
      end

      it "reads EXTRA_BLOCK_MAX_CACHE minutes" do
        ENV["EXTRA_BLOCK_MAX_CACHE"] = "15"
        expect(Decidim::ExtraBlocks.max_cache).to eq(15.minutes)
      end
    end
  end
end
