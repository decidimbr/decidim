# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/proposals"
require "decidim/ephemeral_participation"
require "decidim/toggle"

module Decidim
  module ExtraBlocks
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::ExtraBlocks

      # Deface override files are not Zeitwerk constants (Rails 8 / Decidim 0.32).
      initializer "decidim_extra_blocks.ignore_deface_overrides", before: :set_autoload_paths do
        overrides = root.join("app/overrides")
        Rails.autoloaders.main.ignore(overrides) if overrides.exist?
      end

      initializer "decidim_extra_blocks.content_blocks", after: :load_config_initializers do
        Decidim::ExtraBlocks::ContentBlocks::RegistryManager.register!
      end

      initializer "decidim_extra_blocks.mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::ExtraBlocks::Engine, at: "/", as: "decidim_extra_blocks"
        end
      end

      initializer "decidim_extra_blocks.dummy_ephemeral_authorization" do
        Decidim::Verifications.register_workflow(:dummy_ephemeral_authorization_handler) do |workflow|
          workflow.form = "Decidim::ExtraBlocks::DummyEphemeralAuthorizationHandler"
          workflow.ephemerable = true
        end
      end

      initializer "decidim_extra_blocks.organization_settings_tab",
                  after: "decidim_toggle.organization_settings_tabs" do
        Decidim::ExtraBlocks::SettingsTab.register!
      end

      initializer "decidim_extra_blocks.seed_hook" do
        next if Decidim.singleton_class.ancestors.include?(Decidim::ExtraBlocks::SeedHook)

        Decidim.singleton_class.prepend(Decidim::ExtraBlocks::SeedHook)
      end

      initializer "decidim_extra_blocks.development_csp", after: :load_config_initializers do
        next unless Rails.env.development?

        Decidim.content_security_policies_extra["connect-src"] ||= []
        Decidim.content_security_policies_extra["connect-src"] |= %w(ws://localhost:3035 wss://localhost:3035)
      end

      initializer "decidim_extra_blocks.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("#{Decidim::ExtraBlocks::Engine.root}/app/packs")
      end

      initializer "decidim_extra_blocks.assets.register" do
        next unless root.join("config/assets.rb").exist?

        require root.join("config/assets.rb")
      end

      initializer "decidim_extra_blocks.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExtraBlocks::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::ExtraBlocks::Engine.root}/app/views")
      end

      initializer "decidim_extra_blocks.authorization_handler_extensions" do
        config.to_prepare do
          extension = Decidim::ExtraBlocks::AuthorizationHandlerExtensions
          next if Decidim::AuthorizationHandler.included_modules.include?(extension)

          Decidim::AuthorizationHandler.include(extension)
        end
      end

      initializer "decidim_extra_blocks.direct_upload", after: "decidim_core.direct_uploader_paths" do
        config.to_prepare do
          extension = Decidim::ExtraBlocks::DirectUploadExtensions
          ActiveStorage::DirectUploadsController.prepend(extension) unless ActiveStorage::DirectUploadsController.ancestors.include?(extension)
        end
      end

      # Concern defines create/update via `included` (class_eval on each controller),
      # so prepend on the concern module never overrides those actions — target controllers.
      initializer "decidim_extra_blocks.landing_page_content_blocks" do
        config.to_prepare do
          extension = Decidim::ExtraBlocks::Admin::LandingPageContentBlocksExtensions
          %w(
            Decidim::Admin::OrganizationHomepageContentBlocksController
            Decidim::Admin::StaticPageContentBlocksController
            Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessLandingPageContentBlocksController
            Decidim::ParticipatoryProcesses::Admin::ParticipatoryProcessGroupLandingPageContentBlocksController
            Decidim::Assemblies::Admin::AssemblyLandingPageContentBlocksController
          ).each do |name|
            klass = name.safe_constantize
            next unless klass

            klass.prepend(extension) unless klass.ancestors.include?(extension)
          end
        end
      end

      initializer "decidim_extra_blocks.admin_content_block_cell" do
        config.to_prepare do
          extension = Decidim::ExtraBlocks::Admin::ContentBlockCellExtensions
          cell = Decidim::Admin::ContentBlockCell
          cell.prepend(extension) unless cell.ancestors.include?(extension)
        end
      end

      config.after_initialize do
        form_klass = Decidim::Admin::ContentBlockForm
        unless form_klass.included_modules.include?(Decidim::ExtraBlocks::Admin::ContentBlockFormExtensions)
          form_klass.include(Decidim::ExtraBlocks::Admin::ContentBlockFormExtensions)
        end

        content_block_extension = Decidim::ExtraBlocks::ContentBlockExtensions
        Decidim::ContentBlock.prepend(content_block_extension) unless Decidim::ContentBlock.ancestors.include?(content_block_extension)

        attachment_extension = Decidim::ExtraBlocks::ContentBlockAttachmentExtensions
        Decidim::ContentBlockAttachment.prepend(attachment_extension) unless Decidim::ContentBlockAttachment.ancestors.include?(attachment_extension)

        mailer_extension = Decidim::ExtraBlocks::ApplicationMailerOverride
        unless Decidim::ApplicationMailer.included_modules.include?(mailer_extension)
          Decidim::ApplicationMailer.include(mailer_extension)
        end

        # BetterHtml rejects Decidim core `_wrapper.html.erb` interpolation; keep validating our gem templates.
        if defined?(BetterHtml)
          BetterHtml.configure do |better_config|
            previous = better_config.template_exclusion_filter
            better_config.template_exclusion_filter = proc do |identifier|
              next true if previous&.call(identifier)

              !identifier.to_s.include?("decidim-extra_blocks") &&
                !identifier.to_s.include?("decidim/extra_blocks")
            end
          end
        end
      end
    end
  end
end
