require 'openssl'

module Itamae
  module Secrets
    class Encryptor
      ALGORITHM = 'aes-256-gcm'

      def initialize(plaintext, key = nil, iv = nil)
        ensure_algorithm_key_compatiblity!(key) if key
        @key = key
        @iv = iv
        @plaintext = plaintext
      end

      attr_reader :key, :plaintext

      def key=(other)
        raise "can't overwrite" if @key
        ensure_algorithm_key_compatiblity!(other)
        @key = other
      end

      def to_s
        {
          version: version,
          algorithm: algorithm,
          key_name: key.name,
          ciphertext: ciphertext,
          iv: iv,
          auth_tag: auth_tag,
        }.to_json
      end

      alias data to_s

      def ciphertext
        @ciphertext ||= begin
          data = cipher.update(plaintext)
          data << cipher.final
          @auth_tag = cipher.auth_tag
          [data].pack('m*')
        end
      end

      def iv
        @iv && [@iv].pack('m*')
      end

      def auth_tag
        if @auth_tag
          [@auth_tag].pack('m*')
        else
          raise '[BUG] auth_tag not exists'
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
          c.encrypt
          c.key = key.to_s
          # XXX: avoid generate IV here, but consider if extract to a method like #iv, it have to know Cipher#iv_len...
          @iv ||= c.random_iv
          c.iv = @iv
          c.auth_data = ''
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
