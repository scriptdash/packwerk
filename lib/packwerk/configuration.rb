# typed: true
# frozen_string_literal: true

require "pathname"
require "yaml"

module Packwerk
  class Configuration
    class << self
      def from_path(path = Dir.pwd)
        raise ArgumentError, "#{File.expand_path(path)} does not exist" unless File.exist?(path)

        default_packwerk_path = File.join(path, DEFAULT_CONFIG_PATH)

        if File.file?(default_packwerk_path)
          from_packwerk_config(default_packwerk_path)
        else
          new
        end
      end

      private

      def from_packwerk_config(path)
        new(
          YAML.load_file(path) || {},
          config_path: path
        )
      end
    end

    DEFAULT_CONFIG_PATH = "packwerk.yml"
    DEFAULT_INCLUDE_GLOBS = ["**/*.{rb,rake,erb}"]
    DEFAULT_EXCLUDE_GLOBS = ["{bin,node_modules,script,tmp,vendor}/**/*"]

    attr_reader(
      :include, :exclude, :root_path, :package_paths, :custom_associations, :config_path, :cache_directory,
      :reference_collector, :violation_filter,
    )

    def initialize(configs = {}, config_path: nil)
      @include = configs["include"] || DEFAULT_INCLUDE_GLOBS
      @exclude = configs["exclude"] || DEFAULT_EXCLUDE_GLOBS
      root = config_path ? File.dirname(config_path) : "."
      @root_path = File.expand_path(root)
      @package_paths = configs["package_paths"] || "**/"
      @custom_associations = configs["custom_associations"] || []
      @parallel = configs.key?("parallel") ? configs["parallel"] : true
      @cache_enabled = configs.key?("cache") ? configs["cache"] : false
      @cache_directory = Pathname.new(configs["cache_directory"] || "tmp/cache/packwerk")
      @config_path = config_path
      @reference_collector = nil
      @violation_filter = nil

      if configs.key?("require")
        configs["require"].each do |require_directive|
          ExtensionLoader.load(require_directive, @root_path)
        end
      end

      if configs.key?("reference_collector")
        ExtensionLoader.load(configs["reference_collector"], @root_path)

        ObjectSpace.each_object(Class) do |klass|
          if T.unsafe(klass) < Packwerk::ReferenceCollector && klass != Packwerk::NoOpReferenceCollector
            @reference_collector = T.unsafe(klass).new
          end
        end

        if @reference_collector.nil?
          raise ArgumentError,
            "reference_collector must be of type Packwerk::ReferenceCollector. " \
              "No such class found in #{configs["reference_collector"]}"
        end
      end

      if configs.key?("violation_filter")
        puts configs["violation_filter"]
        ExtensionLoader.load(configs["violation_filter"], @root_path)

        ObjectSpace.each_object(Class) do |klass|
          if T.unsafe(klass) < Packwerk::ViolationFilter && klass != Packwerk::NoOpViolationFilter
            @violation_filter = T.unsafe(klass).new
          end
        end

        if @violation_filter.nil?
          raise ArgumentError,
                "reference_collector must be of type Packwerk::ViolationFilter. " \
              "No such class found in #{configs["violation_filter"]}"
        end
      end
    end

    def load_paths
      @load_paths ||= ApplicationLoadPaths.extract_relevant_paths(@root_path, "test")
    end

    def parallel?
      @parallel
    end

    def cache_enabled?
      @cache_enabled
    end
  end
end
