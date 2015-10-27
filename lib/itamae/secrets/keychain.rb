require 'pathname'
require 'itamae/secrets/aes_key'

module Itamae
  module Secrets
    class Keychain
      class KeyNotFound < StandardError; end

      def initialize(path)
        @path = Pathname.new(path)
      end

      attr_reader :path

      def exist?(name)
        @path.join(name).exist?
      end

      def load(name)
        AesKey.load_json @path.join(name).read
      rescue Errno::ENOENT
        raise KeyNotFound, "Couldn't find key #{name.inspect}"
      end

      def save(key)
        open(@path.join(key.name), 'w', 0600) do |io|
          io.puts key.to_json
        end
      end
    end
  end
end
