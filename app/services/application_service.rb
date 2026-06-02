# Base class for service objects. Encapsulates a single unit of business logic
# behind a `.call` entry point so controllers/workers stay thin.
#
#   result = Comments::CreateService.call(author:, body:)
class ApplicationService
  def self.call(...)
    new(...).call
  end
end
