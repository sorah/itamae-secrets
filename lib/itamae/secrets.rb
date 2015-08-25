require "itamae/secrets/version"
require "itamae/secrets/store"

module Itamae
  def self.Secrets(*args)
    Itamae::Secrets::Store.new *args
  end

  module Secrets
  end

end
