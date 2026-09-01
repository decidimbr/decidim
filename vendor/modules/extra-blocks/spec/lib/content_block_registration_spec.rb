# frozen_string_literal: true

require "spec_helper"

describe "Extra Block content block registration" do
  %i(
    homepage
    participatory_process_homepage
    participatory_process_group_homepage
    assembly_homepage
  ).each do |scope|
    context "for #{scope}" do
      let(:manifest) do
        Decidim.content_blocks.for(scope).find { |cb| cb.name == :extra_block }
      end

      it "registers :extra_block" do
        expect(manifest).to be_present
      end

      it "sets cell paths" do
        expect(manifest.cell).to eq("decidim/extra_blocks/content_blocks/extra_block")
        expect(manifest.settings_form_cell).to eq("decidim/extra_blocks/content_blocks/settings_form")
      end

      it "defines layout and union settings" do
        attrs = manifest.settings.attributes
        expect(attrs[:layout].type).to eq(:string)
        expect(attrs[:title]).to be_present
        expect(attrs[:body]).to be_present
        expect(attrs[:title_position]).to be_present
      end

      it "registers the layout images" do
        expect(manifest.images.map { |image| image[:name] }).to include(
          :background_video_webm, :background_video, :background_image, :side_image, :portrait
        )
      end
    end
  end
end
