# frozen_string_literal: true

require "spec_helper"

module ActiveStorage
  describe Blobs::ProxyController do
    let(:organization) { create(:organization) }
    let(:blob) do
      ActiveStorage::Blob.create_and_upload!(
        io: File.open(Decidim::ExtraBlocks::Engine.root.join("lib/seeds/logo_3.svg")),
        filename: "logo_3.svg",
        content_type: "image/svg+xml"
      )
    end

    it "serves SVG blobs inline" do
      host! organization.host
      get Decidim::ExtraBlocks::PermanentMediaUrl.path(blob)

      expect(response).to have_http_status(:ok)
      expect(response.headers["Content-Type"]).to include("image/svg+xml")
      expect(response.headers["Content-Disposition"]).to match(/\binline\b/)
      expect(response.headers["Content-Disposition"]).not_to match(/\battachment\b/)
    end
  end
end
