class BatchImporter::Row < BatchImporter::Node
  attr_accessor :attributes, :cache, :row_number

  def initialize parent:, row_number:, **attributes
    super parent: parent

    self.cache = {}
    self.attributes = attributes
  end

  def create_or_update
    # Rowの保存処理は基本的にstepsで行います
    true
  end
end
