# frozen_string_literal: true

module CSVStepImporter
  module Model
    class Importer < CSVStepImporter::Node
      attr_accessor :dao_values

      validate :validate_updatable_columns

      delegate :model_class, to: :parent
      delegate :columns, to: :parent
      delegate :updatable_columns, to: :parent
      delegate :dao_values, to: :parent

      def create_or_update
        model_class.import(
          columns,
          dao_values,
          on_duplicate_key_update: updatable_columns,
          validate: false,
          timestamps: false,
        )

        true
      end

      def import(values)
        self.values = values
        save!
      end

      def validate_updatable_columns
        return unless errors.empty?

        if (updatable_columns - columns).present?
          errors[:updatable_columns] << "updatedable_columns must be subset of columns"
        end
      end
    end
  end
end
