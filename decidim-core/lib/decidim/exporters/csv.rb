# frozen_string_literal: true

require "csv"

module Decidim
  module Exporters
    # Exports any serialized object (Hash) into a readable CSV. It transforms
    # the columns using slashes in a way that can be afterwards reconstructed
    # into the original nested hash.
    #
    # For example, `{ name: { ca: "Hola", en: "Hello" } }` would result into
    # the columns: `name/ca` and `name/es`.
    class CSV < Exporter
      # Public: Exports a CSV serialized version of the collection using the
      # provided serializer and following the previously described strategy.
      #
      # Returns an ExportData instance.
      def export(col_sep = Decidim.default_csv_col_sep)
        data = ::CSV.generate(headers:, write_headers: true, col_sep:) do |csv|
          processed_collection.each do |resource|
            csv << headers.map { |header| custom_sanitize(resource[header]) }
          end
        end
        ExportData.new(data, "csv")
      end

      def headers
        @headers ||= processed_collection.each_with_object([]) do |resource, keys|
          keys.replace(keys | resource.keys)
        end
      end

      def headers_without_locales
        resource = first_resource
        return [] unless resource

        @headers_without_locales ||= @serializer.new(resource).run.keys
      end

      protected

      def custom_sanitize(value)
        # rubocop:disable Style/AndOr
        return value unless value.instance_of?(String) and invalid_first_chars.include?(value.first)

        # rubocop:enable Style/AndOr
        value.dup.prepend("'")
      end

      def invalid_first_chars
        %w(= + - @)
      end

      private

      def processed_collection
        @processed_collection ||= each_resource.map { |resource| flatten(@serializer.new(resource).run).deep_dup }
      end

      def flatten(object, key = nil)
        case object
        when Hash
          object.inject({}) do |result, (subkey, value)|
            new_key = key ? "#{key}/#{subkey}" : subkey.to_s
            result.merge(flatten(value, new_key))
          end
        when Array
          { key.to_s => object.compact.join(", ") }
        else
          { key.to_s => object }
        end
      end
    end
  end
end
