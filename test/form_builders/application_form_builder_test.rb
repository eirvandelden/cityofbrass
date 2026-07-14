require "test_helper"

class ApplicationFormBuilderTest < ActionView::TestCase
  # Minimal dummy model: plain Ruby class with ActiveModel-compatible interface
  class DummyModel
    include ActiveModel::Model

    attr_accessor :name, :bio, :age, :score, :active, :status, :starts_at, :born_on,
                  :category_id, :adventure_ids

    validates :name, presence: true

    COLUMN_TYPES = {
      "name"        => :string,
      "bio"         => :text,
      "age"         => :integer,
      "score"       => :float,
      "active"      => :boolean,
      "starts_at"   => :datetime,
      "born_on"     => :date,
      "status"      => :string,
      "category_id" => :integer
    }.freeze

    TypeStub = Struct.new(:type)

    def self.type_for_attribute(attr)
      TypeStub.new(COLUMN_TYPES.fetch(attr.to_s, :string))
    end

    def self.name
      "DummyModel"
    end
  end

  class AttachmentModel < DummyModel
    attr_accessor :file

    def self.attachment_definitions
      { file: {} }
    end
  end

  Category = Struct.new(:id, :name)

  def form_for_model(object = DummyModel.new, &block)
    options = { builder: ApplicationFormBuilder, url: "/dummy", html: { id: "dummy_form" } }
    form_for(object, options, &block)
  end

  def render_input(attribute, object: DummyModel.new, **options)
    output = nil
    form_for_model(object) do |f|
      output = f.input(attribute, options)
    end
    output.to_s
  end

  def render_with_builder(object = DummyModel.new)
    output = nil
    form_for_model(object) do |f|
      output = yield f
    end
    output.to_s
  end

  # ─── Test 1: Required string field ───────────────────────────────────────────

  test "required string field has correct wrapper and label classes" do
    html = render_input(:name)

    assert_match(/class="input string required"/, html)
    assert_match(/class="string required control-label"/, html)
    assert_match(/<abbr title="required">\*<\/abbr>/, html)
  end

  # ─── Test 2: Optional string field ───────────────────────────────────────────

  test "optional string field has optional classes and no abbr" do
    html = render_input(:status)

    assert_match(/class="input string optional"/, html)
    assert_match(/class="string optional control-label"/, html)
    assert_no_match(/<abbr/, html)
  end

  # ─── Test 3: Field with errors ────────────────────────────────────────────────

  test "field with errors adds field_with_errors class and small.error element" do
    model = DummyModel.new
    model.valid?  # trigger validation
    # name is blank so it will have a presence error

    html = render_input(:name, object: model)

    assert_match(/field_with_errors/, html)
    assert_match(/<small class="error">/, html)
  end

  # ─── Test 4: Custom label text ────────────────────────────────────────────────

  test "custom label text overrides default humanized attribute name" do
    html = render_input(:name, label: "Full Name")

    assert_match(/<label[^>]*>Full Name/, html)
    assert_no_match(/<label[^>]*>\s*Name[\s<]/, html)
  end

  # ─── Test 5: Boolean field ────────────────────────────────────────────────────

  test "boolean field renders checkbox and boolean wrapper" do
    html = render_input(:active)

    assert_match(/class="input boolean optional"/, html)
    assert_match(/type="checkbox"/, html)
  end

  # ─── Test 6: Integer field ────────────────────────────────────────────────────

  test "integer field renders number input and integer wrapper" do
    html = render_input(:age)

    assert_match(/class="input integer optional"/, html)
    assert_match(/type="number"/, html)
  end

  # ─── Test 7: Email field ──────────────────────────────────────────────────────

  test "email field renders email input and email wrapper" do
    html = render_input(:status, as: :email)

    assert_match(/class="input email optional"/, html)
    assert_match(/type="email"/, html)
  end

  test "file field renders file input" do
    html = render_input(:status, as: :file)

    assert_match(/class="input file optional"/, html)
    assert_match(/type="file"/, html)
  end

  test "attachment field infers file input" do
    html = render_input(:file, object: AttachmentModel.new)

    assert_match(/class="input file optional"/, html)
    assert_match(/type="file"/, html)
  end

  # ─── Test 8: Select field ─────────────────────────────────────────────────────

  test "select field renders select element within wrapper" do
    html = render_input(:status, as: :select, collection: [ [ "Active", "active" ], [ "Inactive", "inactive" ] ])

    assert_match(/class="input select optional"/, html)
    assert_match(/<select/, html)
    assert_match(/Active/, html)
  end

  test "collection option infers select field" do
    html = render_input(:status, collection: [ [ "Active", "active" ], [ "Inactive", "inactive" ] ])

    assert_match(/class="input select optional"/, html)
    assert_match(/<select/, html)
    assert_no_match(/type="text"/, html)
  end

  test "select field supports string collections without value method" do
    html = render_input(:status, collection: [ "public", "private" ])

    assert_match(/<option value="public">public<\/option>/, html)
    assert_match(/<option value="private">private<\/option>/, html)
  end

  test "grouped select supports string option values without value method" do
    html = render_input(:status, as: :grouped_select, collection: [ [ "Core", [ "Rule", "Feat" ] ] ])

    assert_match(/<optgroup label="Core">/, html)
    assert_match(/<option value="Rule">Rule<\/option>/, html)
    assert_match(/<option value="Feat">Feat<\/option>/, html)
  end

  test "select field uses label and value methods for object collections" do
    categories = [ Category.new(1, "Monsters") ]

    html = render_input(:category_id, as: :select, collection: categories, label_method: :name, value_method: :id)

    assert_match(/<option value="1">Monsters<\/option>/, html)
    assert_no_match(/struct Category/, html)
  end

  test "checkbox collection uses label and value methods for object collections" do
    categories = [ Category.new(1, "Monsters") ]

    html = render_input(:adventure_ids, as: :check_boxes, collection: categories, label_method: :name, value_method: :id)

    assert_match(/type="checkbox"/, html)
    assert_match(/value="1"/, html)
    assert_match(/Monsters/, html)
  end

  # ─── Test 9: Association ──────────────────────────────────────────────────────

  test "association wraps a collection_select for the _id attribute" do
    categories = [ Category.new(1, "Monsters"), Category.new(2, "NPCs") ]

    output = nil
    form_for_model do |f|
      output = f.association(:category, collection: categories, label_method: :name, value_method: :id)
    end
    html = output.to_s

    assert_match(/class="input select optional"/, html)
    assert_match(/<select/, html)
    assert_match(/Monsters/, html)
  end

  # ─── Test 10: wrapper_html class ──────────────────────────────────────────────

  test "wrapper_html class is appended to outer div" do
    html = render_input(:status, wrapper_html: { class: "extra" })

    assert_match(/class="input string optional extra"/, html)
  end

  # ─── Test 11: label: false suppresses the label ───────────────────────────────

  test "label: false suppresses the label entirely" do
    html = render_input(:status, label: false)

    assert_no_match(/<label/, html)
  end

  # ─── Test 12: input_html options are applied to the rendered input ────────────

  test "input_html class is applied to the rendered input" do
    html = render_input(:status, input_html: { class: "my-input" })

    assert_match(/class="my-input"/, html)
  end

  # ─── Test 13: hint text renders a span.hint element ──────────────────────────

  test "hint text renders a span with hint class" do
    html = render_input(:status, hint: "Some hint text")

    assert_match(/<span class="hint">Some hint text<\/span>/, html)
  end

  # ─── Test 14: association with include_blank renders a blank option ───────────

  test "association with include_blank: true renders a blank option" do
    categories = [ Category.new(1, "Monsters") ]

    output = nil
    form_for_model do |f|
      output = f.association(:category, collection: categories, label_method: :name, value_method: :id, include_blank: true)
    end
    html = output.to_s

    assert_match(/<option value=""[^>]*><\/option>/, html)
  end

  test "input_field renders an unwrapped field" do
    html = render_with_builder do |f|
      f.input_field(:status, value: "Draft", disabled: true, readonly: "readonly")
    end

    assert_match(/value="Draft"/, html)
    assert_match(/disabled="disabled"/, html)
    assert_match(/readonly="readonly"/, html)
    assert_no_match(/class="input/, html)
  end

  test "button supports simple form submit signature" do
    html = render_with_builder do |f|
      f.button(:submit, "Save")
    end

    assert_match(/<input type="submit" name="commit" value="Save"/, html)
  end
end
