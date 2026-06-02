require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "requires a body" do
    assert_not build(:comment, body: "").valid?
  end

  test "nests under a parent via ancestry" do
    root = create(:comment)
    child = create(:comment, parent: root)
    assert_equal root, child.parent
    assert_includes root.children, child
    assert_equal 0, root.ancestry_depth
    assert_equal 1, child.ancestry_depth
  end

  test "subtree includes descendants" do
    root = create(:comment)
    child = create(:comment, parent: root)
    grandchild = create(:comment, parent: child)
    assert_equal [ root, child, grandchild ].map(&:id).sort, root.subtree.pluck(:id).sort
  end

  test "searchable? is false for a blank body" do
    assert_not build(:comment, body: "").searchable?
    assert build(:comment, body: "hi").searchable?
  end

  test "as_json_node exposes node and counts" do
    root = create(:comment)
    create(:comment, parent: root)
    node = root.as_json_node
    assert_equal root.id, node[:id]
    assert_equal 0, node[:depth]
    assert_equal 1, node[:children_count]
    assert_nil node[:parent_id]
  end

  test "normalize_body strips html and markdown images" do
    raw = '<img src="/static/media/photo.avif"> hello ![x](/static/media/y.avif)'
    assert_equal "hello", Comment.normalize_body(raw)
  end

  test "normalizes body before save" do
    comment = create(:comment, body: '<img src="/static/media/photo.avif"> kept text')
    assert_equal "kept text", comment.body
    assert_equal "kept text", comment.plain_body
  end
end
