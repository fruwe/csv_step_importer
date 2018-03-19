module BatchImporter
  module Model
    class Reflector < BatchImporter::Node
      delegate :model_class, to: :parent
      delegate :finder_keys, to: :parent
      delegate :finder_scope, to: :parent
      delegate :finder_values, to: :parent
      delegate :daos, to: :parent
      delegate :name, to: :parent

      def create_or_update
        self.dao_ids = ids
        true
      end

      def finder_key
        raise 'not yet supported' unless finder_keys.size == 1
        finder_keys.first
      end

      def find_ids_scope
        finder_scope
          .where(finder_key => finder_values)
          .order(["field(#{finder_key}, ?)", finder_values])
          .pluck(:id)
      end

      def finder_values
        @finder_values ||= daos.collect do |dao|
          dao.value[finder_key]
        end
      end

      def ids
        @ids ||= find_ids_scope.to_a
      end

      # set ids
      def dao_ids= ids
        raise "Unable to find saved data. Please check your scope." unless ids.size == daos.size

        daos.each_with_index do |dao, index|
          dao.id = dao.value[:id] = ids[index]
        end
      end
    end
  end
end
