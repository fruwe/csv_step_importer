# frozen_string_literal: true

module CSVStepImporter
  module Model
    class Importer < CSVStepImporter::Node
      attr_accessor :dao_values

      delegate :model_class, to: :parent
      delegate :columns, to: :parent
      delegate :on_duplicate_key_update, to: :parent
      delegate :dao_values, to: :parent

      def create_or_update
        model_class.import(
          columns,
          dao_values,
          on_duplicate_key_update: on_duplicate_key_update,
          validate: false,
          timestamps: false,
        )

        true
      end

      def import(values)
        self.values = values
        save!
      end
    end
  end
end
