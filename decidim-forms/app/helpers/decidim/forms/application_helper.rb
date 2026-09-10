# frozen_string_literal: true

module Decidim
  module Forms
    # Custom helpers, scoped to the forms engine.
    module ApplicationHelper
      # Show cell for selected models
      def show_public_participation?
        model_name = questionnaire_for.model_name.element

        permitted_models.include?(model_name)
      end

      def permitted_models
        %(meeting)
      end

      def questionnaire_file_upload_help(question, organization = current_organization)
        settings = Decidim.organization_settings(organization)
        messages = []

        if question.max_choices.present?
          messages << t("decidim.forms.questionnaires.file_upload_help.max_files", count: question.max_choices)
        end

        extensions = Array(settings.upload_allowed_file_extensions).compact_blank
        if extensions.any?
          messages << t("decidim.forms.questionnaires.file_upload_help.extensions", extensions: extensions.join(", "))
        end

        maximum_size = settings.upload_maximum_file_size
        if maximum_size.to_i.positive?
          messages << t("decidim.forms.questionnaires.file_upload_help.max_size", size: number_to_human_size(maximum_size))
        end

        messages.join(" ")
      end
    end
  end
end
