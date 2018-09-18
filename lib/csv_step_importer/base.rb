# frozen_string_literal: true

module CSVStepImporter
  class Base
    include ::ActiveModel::Validations
    include ::ActiveModel::Validations::Callbacks
    include ::ActiveModel::Conversion
    extend ::ActiveModel::Naming

    define_callbacks :save

    class CSVImportError < RuntimeError; end
    class CSVFileImportError < CSVImportError; end

    # defines a method with the specified proc or a proc returning the value of the second attribute
    def self.set(name, value_or_proc)
      procedure = value_or_proc.is_a?(Proc) ? value_or_proc : -> { value_or_proc }
      define_method name, procedure
    end

    # do not use transactions by default, override if necessary in subclasses
    # NOTE: Chunk's default is true
    # NOTE: To turn on file wide transactions, use `Loader.set :use_transaction, true`
    set :use_transaction, false

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

        status = if use_transaction
          !!::ActiveRecord::Base.transaction do
            raise ::ActiveRecord::Rollback unless create_or_update
            true
          end
        else
          create_or_update
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
