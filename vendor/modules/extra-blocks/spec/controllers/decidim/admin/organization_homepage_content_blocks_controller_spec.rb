# frozen_string_literal: true

require "spec_helper"

describe Decidim::Admin::OrganizationHomepageContentBlocksController do
  routes { Decidim::Admin::Engine.routes }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:existing_block) do
    create(
      :content_block,
      organization:,
      manifest_name: :extra_block,
      scope_name: :homepage,
      weight: 1,
      published_at: Time.current
    )
  end

  before do
    request.env["decidim.current_organization"] = organization
    sign_in user, scope: :user
  end

  describe "POST #create" do
    it "redirects to the newly created extra_block editor" do
      expect do
        post :create, params: { manifest_name: "extra_block" }
      end.to change(Decidim::ContentBlock.where(organization:, manifest_name: "extra_block"), :count).by(1)

      new_block = Decidim::ContentBlock
                  .where(organization:, manifest_name: "extra_block")
                  .where.not(id: existing_block.id)
                  .sole

      expect(response).to redirect_to(edit_organization_homepage_content_block_path(new_block))
      expect(response.location).not_to include(existing_block.id.to_s)
    end
  end

  describe "PATCH #update" do
    let!(:content_block) do
      create(
        :content_block,
        organization:,
        manifest_name: :extra_block,
        scope_name: :homepage,
        weight: 2,
        published_at: Time.current,
        settings: { "layout" => "verbose_cta", "title" => { "en" => "Hello" } }
      )
    end

    it "sets a success flash and redirects to edit" do
      patch :update, params: {
        id: content_block.id,
        content_block: {
          settings: {
            layout: "verbose_cta",
            title_en: "Updated title"
          }
        }
      }

      expect(flash[:success]).to eq(I18n.t("decidim.extra_blocks.admin.update.success"))
      expect(response).to redirect_to(edit_organization_homepage_content_block_path(content_block))
    end
  end
end
