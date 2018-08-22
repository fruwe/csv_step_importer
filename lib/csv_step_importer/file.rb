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

      self.csv_options = csv_options
      precompile_csv_options!

      load_csv
    end

    def load_csv
      raise CSVFileNotFoundError.new unless ::File.exists? path

      first_row = 2

      ::SmarterCSV.process(path, **csv_options) do |rows|
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

    def precompile_csv_options!
      # set default options
      self.csv_options = {
        chunk_size: 1000,
        file_encoding: "CP932:UTF-8",
      }.merge(csv_options)

      # easier specification of headers, including case case sensitive headers
      if csv_options[:headers] || csv_options[:headers_mode] || csv_options[:case_sensitive_headers]
        if csv_options[:header_transformations]
          raise "either use header_transformations or headers (and case_sensitive_headers optionally)"
        end

        csv_options[:header_transformations] = [ :none ]
        csv_options[:header_transformations] << { key_mapping: csv_options.delete(:headers) } if csv_options[:headers]
        csv_options[:header_transformations] << header_mode_transformer
      end

      # retrieve headers from CSV
      csv_options[:header_transformations] ||= []
      csv_options[:header_transformations] << header_proc
    end

    def header_mode_transformer
      case headers_mode
      when :case_sensitive_symbols
        Proc.new { |headers|
          headers.map { |x| x.strip.gsub(%r{"}, "").gsub(/(\s|\-)+/, "_").to_sym }
        }
      when :case_insensitive_symbols
        # use existing helper
        :keys_as_symbols
      when :symbols
        Proc.new { |headers|
          headers.map { |x| x.strip.to_sym }
        }
      when :preserve
        Proc.new { |headers| headers }
      else
        raise "unknown headers_mode #{headers_mode}"
      end
    end

    def headers_mode
      if csv_options[:case_sensitive_headers]
        ActiveSupport::Deprecation.warn(
          "Key `:case_sensitive_headers` is deprecated, please use `:headers_mode` with a value of" +
          " `:case_sensitive_symbols` instead"
        )

        if csv_options[:headers_mode]
          raise "Key `:case_sensitive_headers` is deprecated, and will be ignored, since headers_mode is specified"
        end

        csv_options.delete(:case_sensitive_headers)
        csv_options[:headers_mode] = :case_sensitive_symbols
      end

      csv_options[:headers_mode] || :preserve
    end
  end
end
