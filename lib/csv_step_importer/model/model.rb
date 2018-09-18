# frozen_string_literal: true

require "active_support/inflector"

module CSVStepImporter
  module Model
    class Model < CSVStepImporter::Node
      attr_accessor :dao_values
      delegate :rows, :cache, to: :parent
      delegate :cache_key, to: :class

      #########################################################
      # Configuration
      #########################################################

      set :columns, -> { raise "please extend and implement" } # example: [:email, :updated_at, :created_at]
      set :composite_key_columns, nil # specify to an array of columns in order filter duplicates from daos
      set :dao_class, CSVStepImporter::Model::DAO

      #########################################################
      # Logic
      #########################################################

      def initialize(**attributes)
        super **attributes

        add_daos
        filter_daos! if composite_key_columns
        add_model_children
      end

      #########################################################
      # Configuration
      #########################################################

      def self.cache_key(pluralize: false)
        key = name.underscore.gsub("/", "_")
        (pluralize ? key.pluralize : key.singularize).to_sym
      end

      #########################################################
      # Logic
      #########################################################

      def add_model_children
        add_children dao_node, prepend: true
      end

      def daos
        dao_node.children
      end

      def dao_values
        @dao_values ||= daos.collect(&:value)
      end

      def dao_node
        @dao_node ||= CSVStepImporter::Node.new parent: self
      end

      def add_daos
        dao_node_children = rows.collect do |row|
          build_daos_for_row row
        end.flatten.compact

        link_rows_to_daos daos: dao_node_children

        dao_node.add_children dao_node_children
      end

      # can return nil, a single object or an array of objects
      def build_daos_for_row(row)
        dao_class.new parent: dao_node, row: row
      end

      # TODO a possible feature would be to add validation errors if the duplicates do not match in all columns (columns other than the composite key)
      def filter_daos!
        unique_daos = {}

        daos.keep_if do |dao|
          hash = dao.values_for(composite_key_columns).hash
          keep = (unique_daos[hash] ||= dao) == dao

          # unlink to be deleted dao and add a link to
          dao.unlink! replace_with: unique_daos[hash] unless keep

          keep
        end
      end

      def link_rows_to_daos(daos:)
        daos.each(&:link!)
      end
    end
  end
end
