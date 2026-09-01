# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ExtraBlocks
    describe ImageCapabilities do
      after { described_class.reset! }

      describe ".vips_webp?" do
        before do
          require "vips"
          allow(ActiveStorage).to receive(:variant_processor).and_return(processor)
        end

        context "when Active Storage uses mini_magick" do
          let(:processor) { :mini_magick }

          it "is false even if libvips can load webp" do
            allow(Vips).to receive(:get_suffixes).and_return([".webp"])
            expect(described_class.vips_webp?).to be(false)
          end
        end

        context "when Active Storage uses vips" do
          let(:processor) { :vips }

          it "is true when libvips supports webp" do
            allow(Vips).to receive(:get_suffixes).and_return([".webp"])
            allow(described_class).to receive(:webp_encode_ok?).and_return(true)
            expect(described_class.vips_webp?).to be(true)
          end

          it "is false when libvips has no webp suffix" do
            allow(Vips).to receive(:get_suffixes).and_return([".png"])
            expect(described_class.vips_webp?).to be(false)
          end

          it "is false when webp encode probe fails" do
            allow(Vips).to receive(:get_suffixes).and_return([".webp"])
            allow(described_class).to receive(:webp_encode_ok?).and_return(false)
            expect(described_class.vips_webp?).to be(false)
          end
        end
      end

      describe ".pngquant?" do
        it "is false when pngquant is missing" do
          allow(described_class).to receive(:system).with("which", "pngquant", out: File::NULL, err: File::NULL).and_return(false)
          described_class.reset!
          expect(described_class.pngquant?).to be(false)
        end

        it "is true when pngquant is on PATH" do
          allow(described_class).to receive(:system).with("which", "pngquant", out: File::NULL, err: File::NULL).and_return(true)
          described_class.reset!
          expect(described_class.pngquant?).to be(true)
        end
      end

      describe ".imagemagick_subsample_mode?" do
        before do
          allow(ActiveStorage).to receive(:variant_processor).and_return(processor)
        end

        context "when Active Storage uses vips" do
          let(:processor) { :vips }

          it "is false without probing convert" do
            expect(Open3).not_to receive(:capture2e)
            expect(described_class.imagemagick_subsample_mode?).to be(false)
          end
        end

        context "when Active Storage uses mini_magick" do
          let(:processor) { :mini_magick }

          before do
            allow(described_class).to receive(:mini_magick_binary).and_return("convert")
          end

          it "is true when convert -help lists -subsample-mode" do
            status = instance_double(Process::Status, success?: true)
            allow(Open3).to receive(:capture2e).with("convert", "-help").and_return(["-subsample-mode on\n", status])
            expect(described_class.imagemagick_subsample_mode?).to be(true)
          end

          it "is false when convert -help omits -subsample-mode" do
            status = instance_double(Process::Status, success?: true)
            allow(Open3).to receive(:capture2e).with("convert", "-help").and_return(["-resize geometry\n", status])
            expect(described_class.imagemagick_subsample_mode?).to be(false)
          end

          it "is false when the help probe fails" do
            allow(Open3).to receive(:capture2e).and_raise(Errno::ENOENT)
            expect(described_class.imagemagick_subsample_mode?).to be(false)
          end
        end
      end

      describe ".webp_saver" do
        it "omits subsample_mode when unsupported" do
          allow(described_class).to receive(:imagemagick_subsample_mode?).and_return(false)
          expect(described_class.webp_saver).to eq(strip: true, interlace: true, quality: 100)
        end

        it "includes subsample_mode when supported" do
          allow(described_class).to receive(:imagemagick_subsample_mode?).and_return(true)
          expect(described_class.webp_saver).to include(subsample_mode: "on", strip: true, quality: 100)
        end
      end
    end
  end
end
