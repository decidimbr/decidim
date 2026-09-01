# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Admin
      module LandingPageContentBlocksExtensions
        def create
          return super unless params[:manifest_name].to_s == "extra_block"

          enforce_permission_to_update_resource

          Decidim::Admin::ContentBlocks::CreateContentBlock.call(
            current_organization,
            content_block_scope,
            params[:manifest_name],
            scoped_resource&.id
          ) do
            on(:ok) do
              flash[:success] = content_block_create_success_text
              block = newly_created_extra_block
              if block
                redirect_to action: :edit, id: block.id
              else
                redirect_to edit_resource_landing_page_path
              end
            end
            on(:invalid) do
              flash[:error] = content_block_create_error_text
              redirect_to edit_resource_landing_page_path
            end
          end
        end

        def update
          return super unless content_block.manifest_name.to_s == "extra_block"

          enforce_permission_to_update_resource
          @form = form(Decidim::Admin::ContentBlockForm).from_params(params, content_block:)
          update_extra_block
        end

        # Public wrapper: upstream keeps edit_resource_landing_page_path private.
        def extra_blocks_edit_resource_landing_page_path
          edit_resource_landing_page_path
        end

        private

        def update_extra_block
          Decidim::Admin::ContentBlocks::UpdateContentBlock.call(@form, content_block, content_block_scope) do
            on(:ok) do
              flash[:success] = I18n.t("decidim.extra_blocks.admin.update.success")
              redirect_to action: :edit, id: content_block.id
            end
            on(:invalid) { render_extra_block_edit_invalid }
          end
        end

        def render_extra_block_edit_invalid
          render "decidim/admin/shared/landing_page_content_blocks/edit", status: :unprocessable_entity
        end

        def newly_created_extra_block
          Decidim::ContentBlock.for_scope(
            content_block_scope,
            organization: current_organization
          ).where(
            manifest_name: "extra_block",
            scoped_resource_id: scoped_resource&.id
          ).reorder(created_at: :desc, id: :desc).first
        end
      end
    end
  end
end
