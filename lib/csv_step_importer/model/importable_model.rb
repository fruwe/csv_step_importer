# frozen_string_literal: true

module CSVStepImporter
  module Model
    class ImportableModel < CSVStepImporter::Model::Model
      #########################################################
      # Configuration
      #########################################################

      # example: User
      set :model_class, -> { raise "please extend and implement" }

      # set to nil in order to deactivate
      set :importer_class, CSVStepImporter::Model::Importer

      # return CSVStepImporter::Model::Reflector in order to enable reflections (e.g. get ids of all rows)
      # disabled by default
      set :reflector_class, nil

      # NOTE: required only when reflector class is set
      # example: env[:company].company_users
      set :finder_scope, -> { model_class.all }

      # NOTE: required only when reflector class is set
      # example: [:email]
      set :finder_keys, -> { composite_key_columns || raise("please extend and implement") }

      # NOTE: required only when importer class is set
      # see: https://github.com/zdennis/activerecord-import/wiki/On-Duplicate-Key-Update
      set :on_duplicate_key_ignore, false

      # NOTE: required only when importer class is set
      # example [:email, :updated_at]
      # see: https://github.com/zdennis/activerecord-import/wiki/On-Duplicate-Key-Update
      set :on_duplicate_key_update, -> { raise "please extend and implement" }

      #########################################################
      # Logic
      #########################################################

      def add_model_children
        add_children [dao_node, importer_class, reflector_class], prepend: true
      end
    end
  end
end
