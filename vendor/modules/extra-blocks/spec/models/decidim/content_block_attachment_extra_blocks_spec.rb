# frozen_string_literal: true

require "spec_helper"

describe Decidim::ContentBlockAttachment do
  let(:organization) { create(:organization) }
  let(:content_block) do
    create(
      :content_block,
      organization:,
      scope_name: :homepage,
      manifest_name: :extra_block
    )
  end

  it "uses the mp4 uploader max size for background_video" do
    attachment = described_class.new(name: "background_video", content_block:)

    expect(attachment.uploader).to eq(Decidim::ExtraBlocks::BackgroundMp4Uploader)
    expect(attachment.maximum_upload_size).to eq(Decidim::ExtraBlocks::BackgroundVideoUploader::MAX_FILE_SIZE)
  end

  it "uses the webm uploader max size for background_video_webm" do
    attachment = described_class.new(name: "background_video_webm", content_block:)

    expect(attachment.uploader).to eq(Decidim::ExtraBlocks::BackgroundWebmUploader)
    expect(attachment.maximum_upload_size).to eq(Decidim::ExtraBlocks::BackgroundVideoUploader::MAX_FILE_SIZE)
  end
end
