# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::ContentBlockForm do
  subject do
    described_class.from_params(params).with_context(
      current_organization: organization,
      content_block:
    )
  end

  let(:organization) { create(:organization) }
  let(:content_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      settings: { "layout" => "verbose_cta", "title" => { "en" => "Hello" } }
    )
  end
  let(:incoming_layout) { "verbose_cta" }
  let(:params) do
    {
      "settings" => {
        "layout" => incoming_layout,
        "title_en" => "Hello",
        "background_color" => "#112233",
        "text_color" => "white"
      },
      "images" => {}
    }
  end

  it "accepts the frozen layout" do
    expect(subject).to be_valid
  end

  context "when trying to change the layout" do
    let(:incoming_layout) { "video_hero" }

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:settings]).to be_present
    end
  end

  context "when layout is unknown" do
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: { "layout" => nil }
      )
    end
    let(:incoming_layout) { "missing_layout" }

    it "is invalid" do
      expect(subject).not_to be_valid
    end
  end

  context "when Fast Proposal default_title is lowercase" do
    let(:incoming_layout) { "focused_quick_proposal" }
    let(:default_title) { "anonymous proposal {{id}}" }
    let(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        settings: {
          "layout" => "focused_quick_proposal",
          "proposal_component_id" => "1",
          "default_title" => "Anonymous Proposal {{id}}",
          "default_title_connected" => "Proposal from {{id}}"
        }
      )
    end
    let(:params) do
      {
        "settings" => {
          "layout" => incoming_layout,
          "proposal_component_id" => "1",
          "default_title" => default_title,
          "default_title_connected" => "Proposal from {{id}}"
        },
        "images" => {}
      }
    end

    it "is invalid" do
      expect(subject).not_to be_valid
      expect(subject.errors[:settings]).to include(
        I18n.t("decidim.extra_blocks.admin.errors.invalid_proposal_title")
      )
    end

    context "when the template is capitalized" do
      let(:default_title) { "Anonymous proposal {{id}}" }

      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
