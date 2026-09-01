# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class ProposalsAsideFastProposalCell < BaseCell
        include FastProposalVisibility

        ASIDE_LIMIT = 3

        def show
          return unless visible?

          render :show
        end

        def background_color
          model.settings.background_color.presence || "#ffffff"
        end

        def prose_classes
          model.settings.text_color.to_s == "white" ? "prose prose-invert" : "prose"
        end

        def eyebrow
          translated_attribute(model.settings.eyebrow)
        end

        def title
          translated_attribute(model.settings.title)
        end

        def description
          translated_attribute(model.settings.description)
        end

        def background_image?
          model.images_container.respond_to?(:background_image) &&
            model.images_container.background_image.attached?
        end

        def background_image_uploader
          return unless background_image?

          model.images_container.attached_uploader(:background_image)
        end

        def aside_proposals
          @aside_proposals ||= if proposal_component.blank?
                                 []
                               else
                                 Decidim::Proposals::Proposal.published
                                                             .where(component: proposal_component)
                                                             .order(Arel.sql("RANDOM()"))
                                                             .limit(ASIDE_LIMIT)
                                                             .to_a
                               end
        end

        def proposal_path(proposal)
          Decidim::ResourceLocatorPresenter.new(proposal).path(anchor: "comments")
        end

        def proposal_snippet(proposal)
          truncate(strip_tags(translated_attribute(proposal.body).to_s), length: 160)
        end
      end
    end
  end
end
