# frozen_string_literal: true

require "smarter_csv"

module CSVStepImporter
  class Loader < CSVStepImporter::Node
    def initialize(file_class: CSVStepImporter::File, chunk_class: CSVStepImporter::Chunk, **attributes)
      super **attributes.slice(:parent, :children, :env)
      add_children attributes[:path] ? file_class.new( **attributes.merge!(chunk_class: chunk_class) ) : chunk_class.new( **attributes )
    end
  end
end
