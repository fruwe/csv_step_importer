module BatchImporter
  module Model
    class Model < BatchImporter::Node
      attr_accessor :dao_values
      delegate :rows, :cache, to: :parent

      def initialize **attributes
        super **attributes

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
        return @dao_node if @dao_node

        @dao_node = BatchImporter::Node.new parent: self

        dao_node_children = rows.collect do |row|
          dao_node = dao_class.new parent: @dao_node, row: row
          row.cache[self.class.cache_key] ||= dao_node
          dao_node
        end

        @dao_node.add_children dao_node_children

        @dao_node
      end
    end
  end
end
