require 'pathname'

require 'itamae/secrets/keychain'
require 'itamae/secrets/encryptor'
require 'itamae/secrets/decryptor'

module Itamae
  module Secrets
    class Store
      def initialize(base_dir)
        @base_dir = Pathname.new(base_dir)
        ensure_base_dir!
      end

      attr_reader :base_dir

      def keychain_path
        base_dir.join('keys')
      end

      def values_path
        base_dir.join('values')
      end

      def keychain
        @keychain ||= Keychain.new(keychain_path)
      end

      def [](name)
        fetch(name, nil)
      end

      def fetch(*args)
        if args.size > 2
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
        end

        name = args[0].to_s
        validate_name!(name)

        value_path = values_path.join(name)

        if value_path.exist?
          encrypted_data = Decryptor.load_json(value_path.read)
          encrypted_data.key = keychain.load(encrypted_data.key_name)
          JSON.parse(encrypted_data.plaintext)['value']
        else
          if args.size == 1
            raise KeyError, "key not found: #{name}"
          else
            args[1]
          end
        end
      end

      def []=(*args)
        case args.size
        when 2
          store(*args)
        when 3
          store(args[0], args[2], args[1])
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 2..3)"
        end
      end

      def store(name, value, key = 'default')
        name = name.to_s
        validate_name!(name)
        value_path = values_path.join(name)

        encrypted_data = Encryptor.new({value: value}.to_json, keychain.load(key))

        open(value_path, 'w', 0600) do |io|
          io.puts encrypted_data.to_s
        end
      end

      private

      def ensure_base_dir!
        unless base_dir.exist?
          Dir.mkdir(base_dir)
        end
        %w(keys values).each do |x|
          path = base_dir.join(x)
          Dir.mkdir(path) unless File.exist?(path)
        end
      end

      def validate_name!(name)
        # XXX: dupe
        raise ArgumentError, "name must not contain slashes, colons, backslackes" if name.include?("\\") || name.include?(?/) || name.include?(?:)
      end
    end
  end
end
