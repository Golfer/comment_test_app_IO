module Comments
  SearchHit = Data.define(
    :id,
    :author_name,
    :body,
    :highlighted_body,
    :source,
    :created_at,
    :root_id
  )
end
