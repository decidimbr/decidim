# frozen_string_literal: true

module Decidim
  module Surveys
    # Exposes the survey resource so users can view and respond them.
    class SurveysController < Decidim::Surveys::ApplicationController
      # i18n-tasks-use t('decidim.surveys.surveys.response.closed')
      # i18n-tasks-use t('decidim.surveys.surveys.response.invalid')
      # i18n-tasks-use t('decidim.surveys.surveys.response.spam_detected')
      # i18n-tasks-use t('decidim.surveys.surveys.response.success')
      include Decidim::Forms::Concerns::HasQuestionnaire
      include Decidim::ComponentPathHelper
      include Decidim::Surveys::SurveyHelper
      include FilterResource
      include Paginable

      helper PublishResponsesHelper
      helper_method :authorizations, :surveys, :show_published_questions_responses?

      before_action :check_permissions, except: [:index]
      # rubocop:disable Rails/LexicallyScopedActionFilter
      before_action :check_open_for_responses, only: [:respond]
      # rubocop:enable Rails/LexicallyScopedActionFilter

      def index; end

      def check_permissions
        render :no_permission unless action_authorized_to(:respond, resource: survey).ok?
      end

      def questionnaire_for
        survey
      end

      protected

      def show_published_questions_responses?
        survey.closed? && survey.questionnaire.questions.pluck(:survey_responses_published_at).any?
      end

      def allow_responses?
        !current_component.published? || survey.open?
      end

      def allow_unregistered?
        survey.allow_unregistered
      end

      def form_path
        main_component_path(current_component)
      end

      private

      # Blocks direct submissions when the survey is closed, since the
      # `:respond` permission is granted unconditionally.
      def check_open_for_responses
        return if survey.open?

        flash[:alert] = t("decidim.surveys.surveys.response.closed")
        redirect_to Decidim::EngineRouter.main_proxy(current_component).survey_path(survey)
      end

      def i18n_flashes_scope
        "decidim.surveys.surveys"
      end

      def surveys
        paginate(search.result).published
      end

      def survey
        @survey ||= search_collection.find_by(id: params[:id])
      end

      def search_collection
        @search_collection ||= Decidim::Surveys::Survey.where(component: current_component)
      end

      def default_filter_params
        {
          with_any_state: %w(open)
        }
      end

      def add_breadcrumb_item
        return {} if survey.blank?

        {
          label: translated_attribute(survey.title),
          url: Decidim::EngineRouter.main_proxy(current_component).survey_path(survey),
          active: false
        }
      end
    end
  end
end
