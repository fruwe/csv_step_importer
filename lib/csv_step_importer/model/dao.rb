# frozen_string_literal: true

module CSVStepImporter
  module Model
    class DAO < CSVStepImporter::Node
      attr_accessor :id, :row, :attributes

      delegate :columns, to: :model
      delegate :dao_for, to: :row

      validates :row, presence: true

      #########################################################
      # Configuration
      #########################################################

      set :created_at, -> { current_timestamp }
      set :updated_at, -> { current_timestamp }

      #########################################################
      # Logic
      #########################################################

      def initialize(parent:, row:, **attributes)
        super parent: parent

        self.attributes = attributes
        self.row = row
      end

      def model
        parent.parent
      end

      # returns an array of all column values, used for batch importing
      def value
        @value ||= columns.each_with_object({}) do |key, values|
          values[key] = value_for_key key
        end
      end

      # retrieve a value for a key from the dao or row
      def value_for_key(key)
        if respond_to?(key)
          send key
        elsif attributes.include? key
          attributes[key]
        elsif row.respond_to?(key)
          row.send key
        elsif row.attributes.include? key
          row.attributes[key]
        else
          nil
        end
      end

      def create_or_update
        # DAOs are usually processed in batches by the model and not saved one by one
        true
      end

      def current_timestamp
        model.cache[:updated_at] ||= (::ActiveRecord::Base.default_timezone == :utc ? ::Time.now.utc : ::Time.now).to_s(:db)
      end

      # link this dao to a row
      def link!
        # add to cache with pluralized key
        (row.cache[model.cache_key(pluralize: true)] ||= []) << self

        # add to cache with singular key (for convenience)
        row.cache[model.cache_key(pluralize: false)] = self
      end

      # unlink this dao from the row and replace it with a different dao
      def unlink!(replace_with: nil)
        cached_daos = row.cache[model.cache_key(pluralize: true)]

        # remove from cache with pluralized key
        cached_daos.delete self
        cached_daos << replace_with

        # set any dao to cache with singular key (for convenience)
        row.cache[model.cache_key(pluralize: false)] = cached_daos.first
      end
    end
  end
end
