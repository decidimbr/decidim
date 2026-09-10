# frozen_string_literal: true

require "decidim/surveys/admin"
require "decidim/surveys/api"
require "decidim/surveys/engine"
require "decidim/surveys/admin_engine"
require "decidim/surveys/component"

module Decidim
  # This namespace holds the logic of the `Surveys` component. This component
  # allows users to create surveys in a participatory process.
  module Surveys
    autoload :UserResponsesSerializer, "decidim/surveys/user_responses_serializer"

    # Whether the admin settings form shows the "allow editing responses"
    # checkbox. Hidden by default so a submitted response stays final unless
    # the instance explicitly opts in.
    mattr_accessor :show_response_editing_setting, default: Decidim::Env.new("SURVEYS_SHOW_RESPONSE_EDITING").present?
  end
end
