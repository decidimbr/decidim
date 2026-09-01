# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Surveys
    describe SurveysController do
      include Decidim::Core::Engine.routes.url_helpers

      let(:survey) { create(:survey, :published, allow_responses:, starts_at:, ends_at:) }
      let(:component) { survey.component }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:allow_responses) { true }
      let(:starts_at) { nil }
      let(:ends_at) { nil }
      let(:params) do
        component.mounted_params.merge(
          id: survey.id,
          questionnaire: { tos_agreement: "1", responses: {} }
        )
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user, scope: :user
      end

      describe "POST respond" do
        context "when the survey is open" do
          before do
            # The polymorphic redirect to the survey record needs the mounted
            # engine context, which is not available in controller specs.
            allow(controller).to receive(:after_response_path).and_return(
              Decidim::EngineRouter.main_proxy(component).survey_path(survey)
            )
          end

          it "accepts the response" do
            post(:respond, params:)

            expect(flash[:notice]).to eq(I18n.t("decidim.surveys.surveys.response.success"))
          end
        end

        context "when the survey does not allow responses" do
          let(:allow_responses) { false }

          it "rejects the submission and redirects back to the survey" do
            post(:respond, params:)

            expect(response).to redirect_to(Decidim::EngineRouter.main_proxy(component).survey_path(survey))
            expect(flash[:alert]).to eq(I18n.t("decidim.surveys.surveys.response.closed"))
          end
        end

        context "when the survey is past its end date" do
          let(:starts_at) { 5.days.ago }
          let(:ends_at) { 2.days.ago }

          it "rejects the submission and redirects back to the survey" do
            post(:respond, params:)

            expect(response).to redirect_to(Decidim::EngineRouter.main_proxy(component).survey_path(survey))
            expect(flash[:alert]).to eq(I18n.t("decidim.surveys.surveys.response.closed"))
          end
        end

        context "when the survey has not started yet" do
          let(:starts_at) { 2.days.from_now }
          let(:ends_at) { 5.days.from_now }

          it "rejects the submission and redirects back to the survey" do
            post(:respond, params:)

            expect(response).to redirect_to(Decidim::EngineRouter.main_proxy(component).survey_path(survey))
            expect(flash[:alert]).to eq(I18n.t("decidim.surveys.surveys.response.closed"))
          end
        end
      end
    end
  end
end
