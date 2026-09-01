# frozen_string_literal: true

require "spec_helper"

describe Decidim::ExtraBlocks::FastProposal::TemplateInterpolator do
  describe ".interpolate" do
    it "substitutes id, random and seconds" do
      expect(
        described_class.interpolate(
          "user_{{id}}_{{random}}_{{seconds}}",
          id: 2,
          random: "123456789",
          seconds: 15
        )
      ).to eq("user_2_123456789_15")
    end
  end

  describe ".valid_nickname_template?" do
    it "accepts valid templates" do
      expect(described_class.valid_nickname_template?("user_{{id}}")).to be(true)
      expect(described_class.valid_nickname_template?("u{{random}}")).to be(true)
    end

    it "rejects nicknames with spaces after substitution" do
      expect(described_class.valid_nickname_template?("user {{id}}")).to be(false)
    end
  end

  describe ".valid_proposal_title_template?" do
    it "rejects a lowercase template" do
      expect(described_class.valid_proposal_title_template?("anonymous proposal {{id}}")).to be(false)
    end

    it "rejects an ALL CAPS template" do
      expect(described_class.valid_proposal_title_template?("ANONYMOUS PROPOSAL {{id}}")).to be(false)
    end

    it "accepts valid default templates" do
      expect(described_class.valid_proposal_title_template?("Anonymous Proposal {{id}}")).to be(true)
      expect(described_class.valid_proposal_title_template?("Proposal from {{id}}")).to be(true)
    end
  end

  describe ".normalize_proposal_title" do
    it "capitalizes the first letter" do
      expect(
        described_class.normalize_proposal_title(
          "anonymous proposal {{id}}",
          id: 2,
          random: "123456789"
        )
      ).to eq("Anonymous proposal 2")
    end
  end
end
