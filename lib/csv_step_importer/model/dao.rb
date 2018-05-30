# frozen_string_literal: true

module CSVStepImporter
  module Model
    class DAO < CSVStepImporter::Node
      attr_accessor :id, :row, :attributes

      delegate :columns, to: :model

      validates :row, presence: true

      def initialize(parent:, row:, **attributes)
        super parent: parent

        self.attributes = attributes
        self.row = row
      end

      def model
        parent.parent
      end

      def value
        @value ||= columns.each_with_object({}) do |key, values|
          values[key] = respond_to?(key) ? send(key) : attributes[key]
        end
      end

      def create_or_update
        # Daoの保存処理は基本的にstepsで行います
        true
      end

      def current_timestamp
        model.cache[:updated_at] ||= (::ActiveRecord::Base.default_timezone == :utc ? ::Time.now.utc : ::Time.now).to_s(:db)
      end

      def created_at
        current_timestamp
      end

      def updated_at
        current_timestamp
      end
    end
  end
end
