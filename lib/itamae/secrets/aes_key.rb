require 'openssl'
require 'json'

module Itamae
  module Secrets
    class AesKey
      AES1_KEY_LEN = OpenSSL::Cipher.new('aes-256-gcm').key_len

      def self.key_len_for_type(type)
        case type
        when 'aes1'
          AES1_KEY_LEN
        else
          raise ArgumentError, "unknown type #{type.inspect}"
        end
      end

      def self.generate_random(name)
        key_len = key_len_for_type('aes1')
        new name, 'aes1', OpenSSL::Random.random_bytes(key_len)
      end

      def self.generate_pkcs5(name, passphrase)
        key_len = key_len_for_type('aes1')

        salt = OpenSSL::Digest::SHA256.digest(name)
        key = OpenSSL::PKCS5.pbkdf2_hmac(passphrase, salt, 30000, key_len, OpenSSL::Digest::SHA256.new)

        new name, 'aes1', key
      end

      def self.load_json(json)
        data = JSON.parse(json)
        new(data['name'], data['type'], data['key'].unpack('m*')[0])
      end

      def initialize(name, type, key)
        raise ArgumentError, "name must not contain slashes, commas, backslackes" if name.include?("\\") || name.include?(?/) || name.include?(?:)
        @name = name
        @type = type
        @key = key
      end

      attr_reader :name, :type, :key

      def algorithm_compatible?(algorithm)
        algorithm == 'aes-256-gcm'
      end

      def to_s
        key
      end

      def to_json
        {
          name: name,
          type: type,
          key: [key].pack('m*'),
        }.to_json
      end
    end
  end
end
