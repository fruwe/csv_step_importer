# frozen_string_literal: true

module BatchImporter
  class Base
    include ::ActiveModel::Validations
    include ::ActiveModel::Validations::Callbacks
    include ::ActiveModel::Conversion
    extend ::ActiveModel::Naming

    define_callbacks :save

    class CSVImportError < RuntimeError; end
    class CSVFileImportError < CSVImportError; end

    def assign_attributes(attributes)
      attributes.each do |key, value|
        send("#{key}=", value)
      end
    end

    def persisted?
      false
    end

    def create_or_update
      raise "please extend and implement"
    end

    def save
      run_callbacks :save do
        return false unless valid?

        status = !!::ActiveRecord::Base.transaction do
          raise ::ActiveRecord::Rollback unless create_or_update
          true
        end

        status
      end
    end

    def save!
      save || raise(CSVFileImportError.new(errors&.messages))
    end

    def update(attributes)
      assign_attributes(attributes)
      save
    end

    def inspect
      to_s
    end

    def to_s
      vars = self.instance_variables.map do |key|
        next if key == :@children
        next if key == :@parent
        next if key == :@env
        next if key == :@errors
        next if key == :@cache
        "#{key}=#{instance_variable_get(key).inspect}"
      end.compact.join(", ")
      "<#{self.class}: #{vars}>"
    end
  end
end
