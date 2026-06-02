module Comments
  # Result object returned by CreateService.
  CreateResult = Data.define(:comment, :errors) do
    def success?
      errors.blank?
    end

    def failure?
      !success?
    end
  end
end
