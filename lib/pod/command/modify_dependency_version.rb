# The CocoaPods modify-dependency-version command.

# The CocoaPods namespace
module Pod
  class Command
    class ModifyDependencyVersion < Command
      self.summary = <<-SUMMARY
          Try to modify specific dependency version by branch name or tag.
      SUMMARY

      self.description = <<-DESC
          Try to modify specific dependency version by branch name or tag.
          In non-verbose mode, '~' indicates the Pod has been modified.
      DESC

      def self.options
        [
            ['--verbose', 'Show change details.'],
            ['--name', 'dependency name'],
            ['--branch', 'use branch name'],
            ['--tag', 'use tag']
        ].concat(super)
      end

      def initialize(argv)
        @check_command_verbose = argv.flag?('verbose')
        @dependency_name = argv.option('name')
        @dependency_branch = argv.option('branch')
        @dependency_tag = argv.option('tag')
        super
      end

      def run
        unless config.podfile
          raise Informative, 'Missing Podfile!'
        end

        raise Informative, 'Missing dependency name!' if @dependency_name == nil
        raise Informative, 'Missing branch name or tag!' if @dependency_branch == nil && @dependency_tag == nil

        results = change_podfile(config)
        print_results(results)
      end

      def change_podfile(config)
        target_pods = {}
        config.podfile.dependencies.each do |dependency|
          if dependency.name == @dependency_name && dependency.external? && (dependency.external_source[:branch] != nil || dependency.external_source[:tag] != nil)
            target_pods[dependency.name] = dependency.external_source.clone
            break
          end
        end

        target_pod_names = target_pods.keys
        return [] if target_pod_names.empty?

        target_pod_names.sort.uniq.map do |spec_name|
          git_path = target_pods[spec_name][:git].gsub("/", '\/')

          source_flag = target_pods[spec_name][:tag] != nil ? "tag" : "branch"
          target_flag = @dependency_tag != nil ? "tag" : "branch"
          source_value = target_pods[spec_name][:tag] != nil ? target_pods[spec_name][:tag] : target_pods[spec_name][:branch]
          target_value = @dependency_tag != nil ? @dependency_tag : @dependency_branch

          exp = "/#{git_path}/s/:#{source_flag}[ ]*=>[ ]*'[^']*'/:#{target_flag} => '#{target_value}'/"
          current_version = "current_#{source_flag}: #{source_value}"
          modify_version = "modify_#{target_flag}: #{target_value}"

          next if exp.empty?

          # sed command
          command = %(sed -i '' -E "#{exp}" Podfile)
          if @check_command_verbose
            UI.puts "Command: #{command}"
          end
          `#{command}`

          # cache changed result
          changed_result(spec_name, current_version, modify_version)
        end.compact
      end

      def changed_result(spec_name, current_version, modify_version)
        if @check_command_verbose
          "#{spec_name} #{current_version} -> #{modify_version}"
        else
          "~#{spec_name}"
        end
      end

      def print_results(results)
        return UI.puts "#{@dependency_name} not found." if results.empty?

        if @check_command_verbose
          UI.puts results.join("\n")
        else
          UI.puts results.join(', ')
        end
      end
    end
  end
end
