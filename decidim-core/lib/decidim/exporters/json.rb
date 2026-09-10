# frozen_string_literal: true

require "json"

module Decidim
  module Exporters
    # Exports a JSON version of a provided hash, given a collection and a
    # Serializer.
    class JSON < Exporter
      # Public: Generates a JSON representation of a collection and a
      # Serializer.
      #
      # Returns an ExportData with the export.
      def export
        data = +"[\n"
        first = true

        each_resource do |resource|
          data << ",\n" unless first
          data << ::JSON.pretty_generate(@serializer.new(resource).run)
          first = false
        end

        data << "\n]"

        ExportData.new(data, "json")
      end
    end
  end
end
