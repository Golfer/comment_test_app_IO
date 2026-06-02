module Comments
  class CreateService < ApplicationService
    def initialize(author:, body:, parent: nil, parent_id: nil)
      @author = author
      @body = body
      @parent = parent || find_parent(parent_id)
      @parent_id = parent_id
    end

    def call
      comment = Comment.new(user: @author, body: @body, parent: @parent)
      return parent_not_found_result(comment) if parent_id_provided_but_missing?

      if comment.save
        Comments::PostCreateJob.perform_later(comment.id)
        CreateResult.new(comment: comment, errors: [])
      else
        CreateResult.new(comment: comment, errors: comment.errors.full_messages)
      end
    end

    private

    def find_parent(parent_id)
      return if parent_id.blank?

      Comment.find_by(id: parent_id)
    end

    def parent_id_provided_but_missing?
      @parent.nil? && @parent_id.present?
    end

    def parent_not_found_result(comment)
      comment.errors.add(:parent, "must exist")
      CreateResult.new(comment: comment, errors: comment.errors.full_messages)
    end
  end
end
