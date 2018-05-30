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

      # set to nil in order to deactivate
      def importer_class
        CSVStepImporter::Model::Importer
      end

      # return CSVStepImporter::Model::Reflector in order to enable reflections (e.g. get ids of all rows)
      # disabled by default
      def reflector_class
        nil
      end

      # NOTE: required only when reflector class is set
      # example: env[:company].company_users
      def finder_scope
        model_class.all
      end

      # NOTE: required only when reflector class is set
      # example: [:email]
      def finder_keys
        raise "please extend and implement"
      end

      # NOTE: required only when importer class is set
      # see: https://github.com/zdennis/activerecord-import/wiki/On-Duplicate-Key-Update
      def on_duplicate_key_ignore
        false
      end

      # NOTE: required only when importer class is set
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
