module Comments
  # Shared page/per normalization for paginated comment queries.
  module Pagination
    def self.page(value)
      [ value.to_i, 1 ].max
    end

    def self.per(value, max:)
      value.to_i.clamp(1, max)
    end
  end
end
