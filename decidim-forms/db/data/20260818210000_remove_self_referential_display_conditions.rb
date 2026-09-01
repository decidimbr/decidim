# frozen_string_literal: true

# Removes display conditions corrupted by the wrong `inverse_of` declared on
# Question#display_conditions_for_other_questions. When the questionnaire was
# re-saved in the admin, that bug overwrote decidim_question_id with the id of
# the condition question, turning the condition self-referential and inert.
# The original owner question cannot be recovered, so the records are deleted.
class RemoveSelfReferentialDisplayConditions < ActiveRecord::Migration[7.2]
  class DisplayCondition < ApplicationRecord
    self.table_name = "decidim_forms_display_conditions"
  end

  def up
    DisplayCondition.where("decidim_question_id = decidim_condition_question_id").delete_all
  end

  def down
    # no-op: corrupted conditions cannot be restored
  end
end
