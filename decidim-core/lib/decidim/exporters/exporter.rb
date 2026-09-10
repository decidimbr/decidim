# frozen_string_literal: true

module Decidim
  module Exporters
    # Abstract class providing the interface and partial implementation
    # of an exporter. See `Decidim::Exporters::JSON` and `Decidim::Exporters::CSV`
    # for a reference implementation.
    class Exporter
      BATCH_SIZE = 1_000

      # Public: Initializes an Exporter.
      #
      # collection - An Array with the collection to be exported.
      # serializer - A Serializer to be used during the export.
      def initialize(collection, serializer = Serializer)
        @collection = collection
        @serializer = serializer
      end

      # Public: Should generate an `ExportData` with the result of the export.
      # Responsibility of the subclass.
      def export
        raise NotImplementedError
      end

      private

      attr_reader :collection, :serializer

      def each_resource
        return enum_for(:each_resource) unless block_given?

        if collection.respond_to?(:find_each)
          collection.find_each(batch_size: BATCH_SIZE) { |resource| yield resource }
        else
          collection.each_slice(BATCH_SIZE) do |batch|
            batch.each { |resource| yield resource }
          end
        end
      end

      def first_resource
        each_resource.first
      end
    end
  end
end
