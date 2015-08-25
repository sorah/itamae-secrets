require 'openssl'

module Itamae
  module Secrets
    class Decryptor
      ALGORITHM = 'aes-256-gcm'

      def self.load_json(json, key = nil)
        data = JSON.parse(json)

        raise ArgumentError, "unknown version #{data['version'].inspect}" if data['version'] != 1
        raise ArgumentError, "unknown version #{data['algorithm'].inspect}" if data['algorithm'] != ALGORITHM

        new(
          data['ciphertext'],
          data['auth_tag'],
          data['iv'],
          data['key_name'],
          key
        )
      end

      def initialize(ciphertext, auth_tag, iv, key_name, key = nil)
        ensure_algorithm_key_compatiblity!(key) if key
        @ciphertext = ciphertext
        @auth_tag = auth_tag
        @iv = iv
        @key_name = key_name
        @key = key
      end

      attr_reader :ciphertext, :auth_tag, :iv, :key_name
      attr_accessor :key

      def key=(other)
        raise "can't overwrite" if @key
        ensure_algorithm_key_compatiblity!(other)
        @key = other
      end

      def plaintext
        @plaintext ||= begin
          txt = cipher.update(ciphertext.unpack('m*')[0])
          txt << cipher.final
        end
      end

      def version
        1
      end

      def algorithm
        ALGORITHM
      end

      def cipher
        @cipher ||= OpenSSL::Cipher.new(algorithm).tap do |c|
          raise 'key is required to proceed' unless key
          c.decrypt
          c.key = key.to_s
          c.iv = iv.unpack('m*')[0]
          c.auth_data = ''
          c.auth_tag = auth_tag.unpack('m*')[0]
        end
      end

      private

      def ensure_algorithm_key_compatiblity!(key)
        unless key.algorithm_compatible?(algorithm)
          raise ArgumentError, "#{key.type} is not compatible"
        end
      end
    end
  end
end

