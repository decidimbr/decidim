# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::ApplicationHelper do
  describe "#questionnaire_file_upload_help" do
    subject(:help_text) { helper.questionnaire_file_upload_help(question, organization) }

    let(:organization) { create(:organization) }
    let(:question) { build(:questionnaire_question, question_type: "files", max_choices: 3) }
    let(:settings) do
      double(
        "organization upload settings",
        upload_allowed_file_extensions: %w(jpg pdf),
        upload_maximum_file_size: 10.megabytes
      )
    end

    before do
      allow(Decidim).to receive(:organization_settings).with(organization).and_return(settings)
    end

    it "describes the maximum file count and the organization upload policy" do
      expect(help_text).to include("Up to 3 files")
      expect(help_text).to include("Accepted formats: jpg, pdf")
      expect(help_text).to include("Maximum size per file: 10 MB")
    end

    context "when no restriction is configured" do
      let(:question) { build(:questionnaire_question, question_type: "files", max_choices: nil) }
      let(:settings) do
        double(
          "organization upload settings",
          upload_allowed_file_extensions: [],
          upload_maximum_file_size: nil
        )
      end

      it { is_expected.to be_blank }
    end
  end
end
