# frozen_string_literal: true

# Decidim 0.29.7 organization factory still assigns attributes removed by later
# migrations in the same release line. Absorb those assignments in test.
return unless defined?(Decidim::Organization)

missing = %i(
  highlighted_content_banner_enabled
  highlighted_content_banner_title
  highlighted_content_banner_short_description
  highlighted_content_banner_action_title
  highlighted_content_banner_action_subtitle
  highlighted_content_banner_action_url
  highlighted_content_banner_image
  user_groups_enabled
  enable_participatory_space_filters
  cta_button_text
  cta_button_path
  official_img_header
).reject { |attr| Decidim::Organization.column_names.include?(attr.to_s) }

Decidim::Organization.class_eval do
  attr_accessor(*missing) if missing.any?
end
