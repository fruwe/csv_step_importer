# frozen_string_literal: true

require "smarter_csv"

module CSVStepImporter
  class File < CSVStepImporter::Node
    class CSVFileNotFoundError < CSVImportError; end

    attr_accessor :chunk_class, :csv_options, :headers, :path, :row_class, :processor_classes, :csv_load_error

    validates :chunk_class, presence: true
    validates :csv_options, presence: true
    validates :path, presence: true
    validates :row_class, presence: true
    validate :validate_csv_load_error

    def initialize(path:, chunk_class: nil, row_class: nil, csv_options: {}, processor_classes: nil, **attributes)
      super **attributes

      self.chunk_class = chunk_class || CSVStepImporter::Chunk
      self.path = path
      self.row_class = row_class || CSVStepImporter::Row
      self.processor_classes = processor_classes

      self.csv_options = {
        chunk_size: 1000,
        file_encoding: "CP932:UTF-8",
      }.merge(csv_options)

      load_csv
    end

    def load_csv
      raise CSVFileNotFoundError.new unless ::File.exists? path

      first_row = 2

      options = csv_options.deep_dup
      options[:header_transformations] ||= []
      options[:header_transformations] << header_proc

      ::SmarterCSV.process(path, **options) do |rows|
        add_children chunk_class.new(
          first_row: first_row,
          parent: self,
          processor_classes: processor_classes,
          row_class: row_class,
          rows: rows,
        )
        first_row += rows.size
      end
    rescue CSVFileNotFoundError => exception
      # File not found
      self.csv_load_error = exception
    rescue ::ArgumentError => exception
      # expected encoding UTF-8, but was Excel
      self.csv_load_error = exception
    rescue ::CSV::MalformedCSVError => exception
      # CSV malformed
      self.csv_load_error = exception
    rescue ::Encoding::InvalidByteSequenceError => exception
      # expected encoding CP932, but was excel file
      self.csv_load_error = exception
    rescue ::EOFError => exception
      # empty file
      self.csv_load_error = exception
    end

    def validate_csv_load_error
      return unless csv_load_error
      errors[:csv_file] << I18n.t("csv_step_importer.errors.#{csv_load_error.class.name.underscore.gsub(/\//, '_')}")
    end

  private
    def header_proc
      Proc.new { |headers|
        self.headers = headers
        headers
      }
    end
  end
end
