# frozen_string_literal: true

module BatchImporter
  class Chunk < BatchImporter::Node
    attr_accessor :cache, :rows

    def initialize(rows: [], row_class: BatchImporter::Row, processor_classes: nil, **attributes)
      super **attributes

      self.cache = {}
      add_rows rows: rows, row_class: row_class
      add_children processor_classes
    end

    def add_rows(rows:, row_class:)
      row_parent_node = BatchImporter::Node.new parent: self

      unless rows.empty? || rows.first.is_a?(row_class)
        row_number = 0
        rows = rows.collect do |row|
          row_class.new(parent: row_parent_node, row_number: row_number += 1, **row)
        end
      end

      @rows = rows

      row_parent_node.add_children rows
      add_children row_parent_node
    end
  end
end
