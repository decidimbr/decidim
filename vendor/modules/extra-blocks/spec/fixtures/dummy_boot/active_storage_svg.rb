# frozen_string_literal: true

# Host apps copy this from the Extra Blocks integrate doc; do not ship it in the Engine.
Rails.application.config.active_storage.content_types_allowed_inline << "image/svg+xml"
Rails.application.config.active_storage.content_types_to_serve_as_binary -= ["image/svg+xml"]
