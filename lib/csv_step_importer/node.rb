# frozen_string_literal: true

module CSVStepImporter
  class Node < CSVStepImporter::Base
    attr_accessor :children
    attr_accessor :parent

    attr_accessor :env

    delegate :cache, to: :root
    delegate :root, to: :parent

    validate :validate_children

    def initialize(parent: nil, children: [], env: nil)
      super()

      self.env = env
      self.parent = parent
      self.children = children
    end

    def env
      @env || parent&.env || {}.freeze
    end

    # childrenはHash型またはArray型です
    def children=(children)
      @children = []
      add_children children
    end

    def add_children(children, prepend: false)
      children = Array(children) unless children.is_a?(Enumerable)

      children = children.collect do |child, sub_children|
        next child unless child.is_a?(Class)
        child.new parent: self, children: sub_children
      end.compact

      @children = prepend ? children + @children : @children + children
    end

    def create_or_update
      children.empty? || children.all?(&:save)
    end

    def validate_children
      return unless errors.empty?

      children.each do |child|
        next if child.valid?
        child.errors.each do |key, message|
          errors[key] << message
        end
      end
    end
  end
end
