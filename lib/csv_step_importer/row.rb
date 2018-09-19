# frozen_string_literal: true

module CSVStepImporter
  class Row < CSVStepImporter::Node
    attr_accessor :attributes, :cache, :row_number

    #########################################################
    # Configuration
    #########################################################

    set :ignore_invalid_rows, false

    #########################################################
    # Logic
    #########################################################

    def initialize(parent:, row_number:, **attributes)
      super parent: parent

      self.cache = {}
      self.attributes = attributes
      self.row_number = row_number
    end

    def create_or_update
      # Rowの保存処理は基本的にstepsで行います
      true
    end

    # retrieve a dao for a different model using the same CSV row. This is useful e.g. if you use the reflector to get ids of related data
    def dao_for(model, pluralize: false)
      cache[model.cache_key(pluralize: pluralize)]
    end

    def include_row?
      ignore_invalid_rows ? valid? : true
    end

    def method_missing(sym,*)
      attributes.fetch(sym){attributes.fetch(sym.to_s){super}}
    end
  end
end
