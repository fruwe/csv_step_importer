class BatchImporter::Model::DAO < BatchImporter::Node
  attr_accessor :id, :row

  delegate :columns, to: :model

  validates :row, presence: true

  def initialize row:, **attributes
    super **attributes

    self.row = row
  end

  def model
    parent.parent
  end

  def value
    @value ||= columns.each_with_object({}) do |key, values|
      values[key] = send key
    end
  end

  def create_or_update
    # Daoの保存処理は基本的にstepsで行います
    true
  end

  def current_timestamp
    model.cache[:updated_at] ||= Time.current.to_s(:db)
  end

  def created_at
    current_timestamp
  end

  def updated_at
    current_timestamp
  end
end
