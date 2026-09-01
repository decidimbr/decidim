# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/extra_blocks/version"

Gem::Specification.new do |s|
  s.version = Decidim::ExtraBlocks.version
  s.authors = ["Hadrien Froger"]
  s.email = ["hadrien@octree.ch"]
  s.license = "AGPL-3.0"
  s.homepage = "https://git.octree.ch/decidim/decidim-modules/decidim-extra-blocks"
  s.required_ruby_version = ">= 3.2.2"

  s.name = "decidim-extra_blocks"
  s.summary = "Layout-based content blocks for Decidim landing pages"
  s.description = "Extra Blocks adds a gallery of frozen layouts (CTA, Hero, Fast Proposal, …) " \
                  "for organization, participatory process, and assembly homepages."

  s.files = Dir[
    "{app,config,db,lib}/**/*",
    "LICENSE.md",
    "Rakefile",
    "README.md",
    "CONTRIBUTING.md",
    "package.json"
  ]

  s.require_paths = ["lib"]
  s.add_dependency "decidim-admin", Decidim::ExtraBlocks.decidim_version
  s.add_dependency "decidim-assemblies", Decidim::ExtraBlocks.decidim_version
  s.add_dependency "decidim-core", Decidim::ExtraBlocks.decidim_version
  s.add_dependency "decidim-ephemeral_participation", "~> 0.0.9"
  s.add_dependency "decidim-participatory_processes", Decidim::ExtraBlocks.decidim_version
  s.add_dependency "decidim-proposals", Decidim::ExtraBlocks.decidim_version
  s.add_dependency "decidim-toggle", "~> 0.1.3"
  s.add_dependency "deface", "~> 1.9"

  s.metadata["rubygems_mfa_required"] = "true"
end
