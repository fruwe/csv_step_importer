module BatchImporter
  class File < BatchImporter::Node
    class CSVFileNotFoundError < CSVImportError; end

    attr_accessor :chunk_class, :csv_options, :path, :row_class, :processor_classes, :csv_load_error

    validates :chunk_class, presence: true
    validates :csv_options, presence: true
    validates :path, presence: true
    validates :row_class, presence: true
    validate :validate_csv_load_error

    def initialize path:, chunk_class: nil, row_class: nil, csv_options: {}, processor_classes: nil, **attributes
      super **attributes

      self.chunk_class = chunk_class || BatchImporter::Chunk
      self.path = path
      self.row_class = row_class || BatchImporter::Row
      self.processor_classes = processor_classes

      self.csv_options = {
        chunk_size: 1000,
        file_encoding: "CP932:UTF-8",
      }.merge(csv_options)

      load_csv
    end

    def load_csv
      raise CSVFileNotFoundError.new unless File.exists? path

      SmarterCSV.process(path, **csv_options.deep_dup) do |rows|
        add_children chunk_class.new parent: self, rows: rows, row_class: row_class, processor_classes: processor_classes
      end
    rescue EOFError
    rescue CSVFileNotFoundError => exception
      self.csv_load_error = exception
    rescue CSV::MalformedCSVError => exception
      self.csv_load_error = exception
    end

    def validate_csv_load_error
      return unless csv_load_error
      errors[:csv_file] << csv_load_error.message
    end
  end
end
