# Base class for query objects. Each query encapsulates one read concern
# (filtering, ordering, shaping) behind a `.call` entry point, keeping
# controllers and models free of ad-hoc scopes.
class ApplicationQuery
  def self.call(...)
    new(...).call
  end
end
