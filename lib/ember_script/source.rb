module EmberScript
  module Source
    def self.bundled_path
      File.expand_path("../../../dist/ember-script.js", __FILE__)
    end
  end
end