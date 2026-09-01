# frozen_string_literal: true

module Decidim
  module ExtraBlocks
    module Layouts
      class LayoutRegistry
        class << self
          ALIASES = { product_roadmap: :roadmap }.freeze

          def register(name)
            manifest = LayoutManifest.new(name: name.to_sym)
            yield(manifest)
            raise ArgumentError, manifest.errors.full_messages.join(", ") unless manifest.valid?

            registry[manifest.name] = manifest
          end

          def find(name)
            return if name.blank?

            registry[ALIASES.fetch(name.to_sym, name.to_sym)]
          end

          def all
            registry.values
          end

          def for_category(category)
            all.select { |manifest| manifest.category.to_sym == category.to_sym }
          end

          def names
            registry.keys
          end

          def categories
            all.map { |manifest| manifest.category.to_sym }.uniq
          end

          def each(&)
            all.each(&)
          end

          def merge_settings!(settings_manifest)
            each do |layout|
              layout.settings.attributes.each do |attr_name, attribute|
                next if settings_manifest.attributes.key?(attr_name)

                settings_manifest.attribute(attr_name, attribute_options_from(attribute))
              end
            end
          end

          def all_images
            each.flat_map { |manifest| Array(manifest.images) }.uniq { |image| image[:name] }
          end

          def reset!
            @registry = {}
          end

          private

          def registry
            @registry ||= {}
          end

          def attribute_options_from(attribute)
            options = {
              type: attribute.type,
              default: attribute.default,
              translated: attribute.translated,
              editor: attribute.editor,
              required: attribute.required,
              required_for_authorization: attribute.required_for_authorization,
              choices: attribute.choices,
              readonly: attribute.readonly,
              preview: attribute.preview,
              include_blank: attribute.include_blank
            }
            options[:raw_choices] = attribute.raw_choices if attribute.respond_to?(:raw_choices)
            options[:units] = attribute.units if attribute.respond_to?(:units)
            options.compact
          end
        end
      end
    end
  end
end
