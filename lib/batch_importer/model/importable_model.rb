class BatchImporter::Model::ImportableModel < BatchImporter::Model::Model
  #########################################################
  # Configuration
  #########################################################

  # example: User
  def model_class
    raise 'please extend and implement'
  end

  def importer_class
    BatchImporter::Model::Importer
  end

  def reflector_class
    BatchImporter::Model::Reflector
  end

  # example: env[:company].company_users
  def finder_scope
    model_class.all
  end

  # example: [:email]
  def finder_keys
    raise 'please extend and implement'
  end

  # example: [:email, :updated_at, :created_at]
  def columns
    raise 'please extend and implement'
  end

  # example [:email, :updated_at]
  def updatable_columns
    raise 'please extend and implement'
  end

  #########################################################
  # Logic
  #########################################################

  def add_model_children
    add_children [dao_node, importer_class, reflector_class], prepend: true
  end
end
