# frozen_string_literal: true

class RemoveAllowEditingResponsesFromDecidimSurveysSurveys < ActiveRecord::Migration[8.0]
  def change
    remove_column :decidim_surveys_surveys, :allow_editing_responses, :boolean
  end
end
