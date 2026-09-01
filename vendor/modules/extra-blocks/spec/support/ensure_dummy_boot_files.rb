# frozen_string_literal: true

# spec/decidim_dummy_app is gitignored; generators or cleanups sometimes drop
# secrets.yml / decidim.rb. Decidim 0.29 needs them; 0.32 must not load them.
module Decidim
  module ExtraBlocks
    module EnsureDummyBootFiles
      module_function

      def call
        restore("active_storage_svg.rb", "config/initializers/active_storage_svg.rb")
        return remove_legacy_files unless legacy_decidim?

        restore("secrets.yml", "config/secrets.yml")
        restore("decidim.rb", "config/initializers/decidim.rb")
      end

      def legacy_decidim?
        Gem.loaded_specs.fetch("decidim-core").version < Gem::Version.new("0.32")
      end

      def remove_legacy_files
        FileUtils.rm_f(File.join(Decidim::Dev.dummy_app_path, "config/secrets.yml"))
        FileUtils.rm_f(File.join(Decidim::Dev.dummy_app_path, "config/initializers/decidim.rb"))
      end

      def restore(source_name, destination)
        destination = File.join(Decidim::Dev.dummy_app_path, destination)
        return if File.exist?(destination)

        FileUtils.mkdir_p(File.dirname(destination))
        FileUtils.cp(File.expand_path("../fixtures/dummy_boot/#{source_name}", __dir__), destination)
      end
    end
  end
end

Decidim::ExtraBlocks::EnsureDummyBootFiles.call
