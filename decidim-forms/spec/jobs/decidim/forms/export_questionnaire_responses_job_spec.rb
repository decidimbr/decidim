# frozen_string_literal: true

require "spec_helper"

describe Decidim::Forms::ExportQuestionnaireResponsesJob do
  subject { described_class }

  let!(:user) { create(:user, :admin) }
  let!(:title) { "The responses" }
  let!(:questionnaire) { create(:questionnaire) }
  let!(:questions) { create_list(:questionnaire_question, 3, questionnaire:) }
  let!(:responses) { questions.map { |q| create(:response, question: q, questionnaire:) } }
  let!(:collection) { [responses] }

  describe "queue" do
    it "is queued to events" do
      expect(subject.queue_name).to eq "exports"
    end
  end

  describe "when everything is OK" do
    let(:mailer) { double :mailer }

    it "sends an email" do
      allow(Decidim::ExportMailer)
        .to receive(:export)
        .and_return(mailer)
      expect(mailer)
        .to receive(:deliver_later)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when exporting fails" do
    it "sends an explicit failure notification and re-raises the error" do
      failure_mail = double(deliver_later: true)

      allow(Decidim::Exporters::FormPDF).to receive(:new).and_raise(StandardError, "PDF generation failed")
      expect(Decidim::ExportMailer).to receive(:export_failed).with(user, title, "PDF generation failed").and_return(failure_mail)
      expect(Decidim::ExportMailer).not_to receive(:export)

      expect { subject.perform_now(user, title, collection) }.to raise_error(StandardError, "PDF generation failed")
    end
  end

  describe "when no responses" do
    it "does not send the email" do
      collection = []

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when no user" do
    it "does not send the email" do
      user = nil

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end

  describe "when user has no email" do
    it "does not send the email" do
      user.update(email: "")

      expect(Decidim::ExportMailer)
        .not_to receive(:export)

      subject.perform_now(user, title, collection)
    end
  end
end
