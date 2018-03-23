# frozen_string_literal: true

module CSVStepImporter
  module Model
    class ImportableModel < CSVStepImporter::Model::Model
      #########################################################
      # Configuration
      #########################################################

      # example: User
      def model_class
        raise "please extend and implement"
      end

      def importer_class
        CSVStepImporter::Model::Importer
      end

      def reflector_class
        CSVStepImporter::Model::Reflector
      end

      # example: env[:company].company_users
      def finder_scope
        model_class.all
      end

      # example: [:email]
      def finder_keys
        raise "please extend and implement"
      end

      # example [:email, :updated_at]
      # see: https://github.com/zdennis/activerecord-import/wiki/On-Duplicate-Key-Update
      def on_duplicate_key_update
        raise "please extend and implement"
      end

      #########################################################
      # Logic
      #########################################################

      def add_model_children
        add_children [dao_node, importer_class, reflector_class], prepend: true
      end
    end
  end
end
