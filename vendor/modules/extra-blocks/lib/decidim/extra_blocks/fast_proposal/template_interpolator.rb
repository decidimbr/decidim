# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module FastProposal
      # Interpolates {{id}} / {{random}} (and {{seconds}}) in Fast Proposal templates.
      module TemplateInterpolator
        SAMPLE_ID = "2"
        SAMPLE_RANDOM = "123456789"
        TITLE_LENGTH = 15..150

        class TitleProbe
          include ActiveModel::Model

          attr_accessor :title
        end

        module_function

        def interpolate(template, id:, random:, seconds: nil)
          result = template.to_s
                           .gsub("{{id}}", id.to_s)
                           .gsub("{{random}}", random.to_s)
          result = result.gsub("{{seconds}}", seconds.to_s) unless seconds.nil?
          result
        end

        def valid_nickname_template?(template)
          nickname = interpolate(template, id: SAMPLE_ID, random: SAMPLE_RANDOM)
          return false if nickname.blank?
          return false if nickname.length > Decidim::User.nickname_max_length
          return false unless nickname.match?(Decidim::UserBaseEntity::REGEXP_NICKNAME)

          true
        end

        def interpolate_proposal_title(template, id:, random:)
          title = interpolate(template, id:, random:).strip
          title.length < TITLE_LENGTH.begin ? "#{title} #{random}" : title
        end

        def normalize_proposal_title(template, id:, random:)
          interpolate_proposal_title(template, id:, random:).sub(/\A[[:lower:]]/, &:upcase)
        end

        def valid_proposal_title?(title)
          text = title.to_s
          return false unless TITLE_LENGTH.cover?(text.length)
          return true unless etiquette_enabled?

          etiquette_valid?(text)
        end

        def valid_proposal_title_template?(template)
          title = interpolate_proposal_title(template, id: SAMPLE_ID, random: SAMPLE_RANDOM)
          valid_proposal_title?(title)
        end

        def etiquette_enabled?
          return true unless Decidim.respond_to?(:enable_etiquette_validator)

          Decidim.enable_etiquette_validator
        end

        def etiquette_valid?(text)
          probe = TitleProbe.new(title: text)
          ::EtiquetteValidator.new(attributes: [:title]).validate_each(probe, :title, text)
          probe.errors.empty?
        end
      end
    end
  end
end
