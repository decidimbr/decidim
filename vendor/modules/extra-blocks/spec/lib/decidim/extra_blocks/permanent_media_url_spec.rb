# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe PermanentMediaUrl do
      let(:organization) { create(:organization) }
      let(:blob) do
        ActiveStorage::Blob.create_and_upload!(
          io: StringIO.new("fake-png-bytes"),
          filename: "hero.png",
          content_type: "image/png"
        )
      end

      it "returns a proxy path without redirect and without expiry params" do
        path = described_class.path(blob)

        expect(path).to be_present
        expect(path).to include("/rails/active_storage/blobs/proxy/")
        expect(path).not_to include("/blobs/redirect/")
        expect(path).not_to include("/disk/")
      end
    end
  end
end
