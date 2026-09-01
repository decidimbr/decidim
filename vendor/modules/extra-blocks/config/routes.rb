# frozen_string_literal: true

Decidim::ExtraBlocks::Engine.routes.draw do
  scope :extra_blocks do
    resources :fast_proposals, only: [:create]
  end
end
