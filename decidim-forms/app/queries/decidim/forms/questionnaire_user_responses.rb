# frozen_string_literal: true

module Decidim
  module Forms
    # A class used to collect user responses for a questionnaire
    class QuestionnaireUserResponses < Decidim::Query
      include Enumerable

      BATCH_SIZE = Decidim::Exporters::Exporter::BATCH_SIZE

      class ResponseSet < SimpleDelegator
        attr_reader :questions

        def initialize(responses, questions:)
          super(responses)
          @questions = questions
        end
      end

      # Syntactic sugar to initialize the class and return the queried objects.
      #
      # questionnaire - a Questionnaire object
      def self.for(questionnaire)
        new(questionnaire).query
      end

      # Initializes the class.
      #
      # questionnaire = a Questionnaire object
      def initialize(questionnaire)
        @questionnaire = questionnaire
      end

      # Finds and group responses by user for each questionnaire's question.
      def query
        self
      end

      def each
        return enum_for(:each) unless block_given?

        participants.find_each(batch_size: BATCH_SIZE) do |participant|
          participant_responses = responses.where(session_token: participant.session_token).order("decidim_forms_questions.position ASC").to_a
          next if participant_responses.empty?

          yield ResponseSet.new(participant_responses, questions:)
        end
      end

      def count
        responses.distinct.count(:session_token)
      end
      alias size count

      def empty?
        !responses.exists?
      end

      def first(limit = nil)
        return each.take(limit) if limit

        each.take(1).first
      end

      def to_a
        each.to_a
      end
      alias to_ary to_a

      private

      def participants
        QuestionnaireParticipants.new(@questionnaire).participants
      end

      def responses
        @responses ||= Response.not_separator
                               .not_title_and_description
                               .joins(:question)
                               .includes(:attachments, :user, question: [:matrix_rows, :response_options], choices: [:matrix_row, :response_option])
                               .where(questionnaire: @questionnaire)
      end

      def questions
        @questions ||= @questionnaire.questions.not_separator.not_title_and_description.order(:position).to_a
      end
    end
  end
end
