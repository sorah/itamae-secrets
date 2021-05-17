require 'thor'
require 'yaml'
require 'pathname'

require 'itamae/secrets/aes_key'
require 'itamae/secrets/store'

module Itamae
  module Secrets
    class Cli < Thor
      class_option :base, type: :string, desc: 'path to base directory for storing secrets and keys'


      desc 'newkey [KEYNAME]', 'generate then save key'
      method_option :method, type: :string, required: true, desc: 'generating method (aes-random, aes-passphrase)'
      method_option :confirm_passphrase, type: :boolean, default: true, desc: 'Confirm passphrase when asking'

      def newkey(name='default')
        if keychain.exist?(name)
          raise ArgumentError, "key #{name} already exists"
        end

        key = case options[:method] || config['generate_method']
        when 'aes-random'
          AesKey.generate_random(name)
        when 'aes-passphrase'
          passphrase = ask_noecho('Passphrase:', $stdin.tty?)
          AesKey.generate_pkcs5(name, passphrase)
        else
          raise ArgumentError, "Unknown method: #{options[:method] || config['generate_method']}"
        end

        keychain.save(key)
      end

      desc 'set VARNAME [VALUE]', 'store value (when VALUE is omitted, read from STDIN)'
      method_option :key, type: :string, default: 'default', desc: 'key name'
      method_option :noecho, type: :boolean, desc: 'Ask one-line value with noecho when stdin is tty'
      def set(name, value = nil)
        value ||= if options[:noecho]
                    ask_noecho("#{name}:", false)
                  else
                    $stdin.read.chomp
                  end

        store.store(name, value, options[:key])
      end

      desc 'get VARNAME', 'read value'
      def get(name)
        value = store[name]
        if value
          puts value
        else
          exit 1
        end
      end

      private

      def store
        @store ||= Store.new base_dir
      end

      def keychain
        store.keychain
      end

      def base_dir
        unless config['base']
          raise ArgumentError, 'Missing --base'
        end
        Pathname.new config['base']
      end

      def config
        @config ||= config_file.merge(
          'base' => config_file['base'] || options[:base],
        )
      end

      def config_file
        @config_file ||= if File.exist?('./.itamae-secrets.yml')
          YAML.load_file('./.itamae-secrets.yml')
        else
          {}
        end
      end

      def ask_noecho(prompt, confirm = true)
        io_console = false
        begin
          require 'io/console'
          io_console = true
        rescue LoadError
        end

        get = -> do
          if $stdin.tty?
            $stdin.noecho { $stdin.gets.chomp }
          else
            $stdin.gets.chomp
          end
        end

        loop do
          $stdout.print "#{prompt} "
          value = get.call

          break value unless confirm

          $stdout.print "(confirm) #{prompt} "
          break value if value  == get.call

          $stderr.puts "Confirmation didn't match..."
        end
      end
    end
  end
end
