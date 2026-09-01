# frozen_string_literal: true

require "i18n/tasks"

describe "I18n sanity" do
  let(:locales) do
    ENV["ENFORCED_LOCALES"].presence || "en,pt-BR"
  end

  let(:i18n) { I18n::Tasks::BaseTask.new(locales: locales.split(",")) }
  # Locale-tree parity only (:diff). Skip :used — cell relative keys need heavier i18n-tasks scan config.
  let(:missing_keys) { i18n.missing_keys(types: %i[diff]) }

  it "does not have missing keys across enforced locales" do
    expect(missing_keys).to be_empty,
                            "Missing #{missing_keys.leaves.count} i18n keys, please run `ENFORCED_LOCALES=#{locales} bundle exec i18n-tasks missing -t diff --locales #{locales}` to show them"
  end
end
