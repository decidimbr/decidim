# frozen_string_literal: true

require "spec_helper"

module ActiveStorage
  describe DirectUploadsController do
    describe "POST #create" do
      let(:checksum) { OpenSSL::Digest.base64digest("MD5", "Hello") }
      let(:byte_size) { 6 }
      let(:filename) { "hero.mp4" }
      let(:content_type) { "video/mp4" }
      let(:blob) do
        {
          filename:,
          byte_size:,
          checksum:,
          content_type:
        }
      end
      let(:file_upload_settings) do
        {
          "allowed_file_extensions" => {
            "default" => %w(jpg),
            "admin" => %w(jpg),
            "image" => %w(jpg)
          },
          "allowed_content_types" => {
            "default" => %w(image/jpeg),
            "admin" => %w(image/jpeg)
          },
          "maximum_file_size" => { "default" => 1, "avatar" => 1 }
        }
      end
      let(:organization) { create(:organization, file_upload_settings:, favicon: nil, official_img_footer: nil) }
      let!(:user) { create(:user, :admin, :confirmed, organization:, avatar: nil) }
      let(:params) { { blob:, direct_upload: blob } }

      before do
        request.env["decidim.current_organization"] = organization
        request.headers["HTTP_REFERER"] = "http://#{organization.host}"
        sign_in user
      end

      it "accepts mp4 even when org settings disallow it" do
        post(:create, params:)

        expect(response).to have_http_status(:ok)
        expect(response.body).to include("content_type")
      end

      context "with a webm upload" do
        let(:filename) { "hero.webm" }
        let(:content_type) { "video/webm" }

        it "accepts webm even when org settings disallow it" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
        end
      end

      context "when the mp4 is heavier than the org max but under the video max" do
        let(:byte_size) { 50.megabytes }

        it "accepts the upload" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
        end
      end

      context "when the mp4 exceeds the video max" do
        let(:byte_size) { Decidim::ExtraBlocks::BackgroundVideoUploader::MAX_FILE_SIZE + 1 }

        it "rejects the upload" do
          post(:create, params:)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "with an svg upload" do
        let(:filename) { "logo.svg" }
        let(:content_type) { "image/svg+xml" }

        it "accepts svg even when org settings disallow it" do
          post(:create, params:)

          expect(response).to have_http_status(:ok)
        end
      end

      context "when the file is not a hero video format" do
        let(:filename) { "notes.txt" }
        let(:content_type) { "text/plain" }

        it "keeps org validation (rejects)" do
          post(:create, params:)

          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end
end
