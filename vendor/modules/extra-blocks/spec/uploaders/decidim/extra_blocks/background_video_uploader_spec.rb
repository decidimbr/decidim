# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe BackgroundVideoUploader do
      subject { described_class.new(double, :background_video) }

      it "allowlists mp4 and webm" do
        expect(subject.extension_allowlist).to eq(%w(mp4 webm))
        expect(subject.content_type_allowlist).to include("video/mp4", "video/webm")
      end

      it "defines a video-scoped max file size above org defaults" do
        expect(described_class::MAX_FILE_SIZE).to eq(1.gigabyte)
        expect(described_class::MAX_FILE_SIZE).to be > 10.megabytes
      end
    end

    describe BackgroundWebmUploader do
      subject { described_class.new(double, :background_video_webm) }

      it "allowlists webm only" do
        expect(subject.extension_allowlist).to eq(%w(webm))
        expect(subject.content_type_allowlist).to eq(%w(video/webm audio/webm))
        expect(subject.extension_allowlist).not_to include("mp4")
        expect(subject.content_type_allowlist).not_to include("video/mp4", "application/mp4")
      end
    end

    describe BackgroundMp4Uploader do
      subject { described_class.new(double, :background_video) }

      it "allowlists mp4 only" do
        expect(subject.extension_allowlist).to eq(%w(mp4))
        expect(subject.content_type_allowlist).to eq(%w(video/mp4 application/mp4))
        expect(subject.extension_allowlist).not_to include("webm")
        expect(subject.content_type_allowlist).not_to include("video/webm", "audio/webm")
      end
    end
  end
end
