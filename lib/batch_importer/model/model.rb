require 'active_support/inflector'

module BatchImporter
  module Model
    class Model < BatchImporter::Node
      attr_accessor :dao_values
      delegate :rows, :cache, to: :parent

      def initialize **attributes
        super **attributes

        add_daos
        add_model_children
      end

      #########################################################
      # Configuration
      #########################################################

      def self.cache_key
        name.underscore.split('/').last.to_sym
      end

      def dao_class
        BatchImporter::Model::DAO
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
        @dao_node ||= BatchImporter::Node.new parent: self
      end

      def add_daos
        dao_node_children = rows.collect do |row|
          build_daos_for_row row
        end.flatten

        dao_node.add_children dao_node_children
      end

      def build_daos_for_row row
        # build dao
        dao = dao_class.new parent: dao_node, row: row

        # add dao to cache
        (row.cache[self.class.cache_key.to_s.pluralize.to_sym] ||= []) << dao
        row.cache[self.class.cache_key] = dao

        dao
      end
    end
  end
end
