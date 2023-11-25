require "spec_helper"

RSpec.describe Itamae::Secrets::Store do
  subject(:store) { described_class.new(base_path) }

  let(:base_path) { RSPEC_TEMP_PATH }

  describe '.fetch' do
    subject(:store_fetch) { store.fetch('foo') }

    context 'when arguments excced 2' do
      subject(:store_fetch) { store.fetch('foo', 'bar', 'baz') }

      it { expect { store_fetch }.to raise_error(ArgumentError) }
    end

    context 'when key is not found' do
      it 'returns key error' do
        expect { store_fetch }.to raise_error(KeyError, /key not found: foo/)
      end
    end

    context 'when key is not valid' do
      subject(:store_fetch) { store.fetch(invalid_key) }

      let(:invalid_key) { %w(foo:bar foo\\bar foo/bar).sample }

      it 'returns argument error for names having slashes, colons or backslashes' do
        expect { store_fetch }
          .to raise_error(ArgumentError, /name must not contain slashes, colons, backslackes/)
      end
    end
  end
end
