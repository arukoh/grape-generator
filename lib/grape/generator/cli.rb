require_relative 'version'

require 'thor'
require 'ostruct'
require 'pathname'

module Grape
  module Generator
    class CLI < Thor
      class << self
        def source_root
          'templates'
        end
      end

      include Thor::Actions

      class_option :verbose, type: :boolean, aliases: '-V', default: false

      desc "new NAME", "Generate project scaffolding."
      option :rails, type: :boolean, aliases: '-r', default: false,
                     desc: "Generate the ORM with Rails"
      option :rails_new_options, type: :string, default: '-fBJST',
                     desc: "Options for rails new"
      def new(name)
        @config = {capture: !options[:verbose], verbose: true}
        current_dir = Pathname.pwd
        case name
        when "."
          app_name = current_dir.basename.to_path
          work_dir = current_dir
        else
          raise "#{name} is already exists." if File.exists?(name)
          app_name = name
          work_dir = current_dir.join(name)
        end

        params = { app: {name: app_name} }
        Dir[File.join(template_base, "**", "{*.*,.keep}")].each do |src|
          dst = Pathname.new src.sub(template_base, work_dir.to_path)
          template(src, dst.sub_ext("").to_path, params)
        end

        if options[:rails]
          rails_dir = work_dir.join("rails")
          setup_dir = work_dir.join(app_name)
          rails_new(setup_dir, options[:rails_new_options], params)

          Dir[File.join(template_rails, "**", "{*.*,.keep}")].each do |src|
            dst = Pathname.new src.sub(template_rails, work_dir.to_path)
            dst_path = dst.sub_ext("").to_path
            template(src, dst_path, params.merge(force: :true))
          end

          inside(work_dir, @config) do
            exec(["mv #{setup_dir.to_path} #{rails_dir.to_path}"])
          end
        end

        inside(work_dir, @config) do |dst|
          exec([ "bundle install --path vendor/bundle --without production" ])
        end
      rescue
        puts $!.backtrace
        error_and_exit($!.message)
      end


      no_tasks do
        def templates_path(*item)
          File.expand_path(File.join(File.dirname(__FILE__), ["templates"] + item))
        end

        def template_base
          @template_base ||= templates_path('base')
        end

        def template_rails
          @template_rails ||= templates_path('rails')
        end

        def error_and_exit(status)
          error(status)
          exit(1)
        end

        def exec(commands)
          commands.map do |cmd|
            run cmd, @config
            raise "Failed in exec `#{cmd}`" unless $?.exitstatus == 0
          end
        end

        def run_ruby(cmd)
          run("bundle exec ruby -e \"#{cmd.join(";")}\"", capture: true, verbose: false).chomp
        end

        def build_params(work_dir, app_name)
        end

        def database_gem_entry(database)
          run_ruby([
            "require 'rails'",
            "require 'rails/generators'",
            "require 'rails/generators/rails/app/app_generator'",
            "options = {}",
            database ? "options[:database] = database" : "",
            "generator = Rails::Generators::AppGenerator.new ['rails'], options",
            "gem_name, gem_version = generator.send('gem_for_database')",
            "puts File.readlines('Gemfile').find{|line| line =~ /^gem '\#{gem_name}/ }.chomp",
          ])
        end

        def rails_new(dir, options, params)
          inside(dir, @config) do |dst|
            exec([
              "bundle init",
              "echo \"gem 'rails'\" >> Gemfile",
              "bundle install --path ../vendor/bundle --without production",
              "bundle exec rails new . #{options}",
              "bundle install",
              "mv db ../",
              "ln -s ../db db",
            ])
            options =~ /-d (.+)/i
            params[:app][:database_gem_entry] = database_gem_entry($1)
          end

          inside(dir.join("app"), @config) do
            exec([
              "mv models ../../app",
              "ln -s ../../app/models models",
            ])
          end

          inside(dir.join("config"), @config) do
            exec([
              "mv database.yml ../../config",
              "ln -s ../../config/database.yml database.yml",
            ])
          end
        end
      end
    end
  end
end
