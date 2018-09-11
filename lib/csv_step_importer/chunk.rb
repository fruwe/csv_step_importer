# frozen_string_literal: true

module CSVStepImporter
  class Chunk < CSVStepImporter::Node
    attr_accessor :cache, :rows, :first_row

    def initialize(rows: [], row_class: CSVStepImporter::Row, processor_classes: nil, first_row: 0, **attributes)
      super **attributes

      self.cache = {}
      self.first_row = first_row

      add_rows rows: rows, row_class: row_class
      add_children processor_classes
    end

    def add_rows(rows:, row_class:)
      row_parent_node = CSVStepImporter::Node.new parent: self

      unless rows.empty? || rows.first.is_a?(row_class)
        row_number = self.first_row - 1
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
