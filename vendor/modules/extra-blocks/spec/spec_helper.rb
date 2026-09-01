# frozen_string_literal: true

require "decidim/dev"
require "fileutils"
Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))
require_relative "support/ensure_dummy_boot_files"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)
ENV["NODE_ENV"] ||= "test"
ENV["DISABLE_SPRING"] ||= "1"

require "decidim/dev/test/map_server"
require "decidim/dev/test/base_spec_helper"
require "decidim/core/test/factories"
require "decidim/system/test/factories"
require "decidim/participatory_processes/test/factories"
require "decidim/proposals/test/factories"

Dir[File.expand_path("support/**/*.rb", __dir__)].each { |f| require f }
