class ApplicationFormBuilder < ActionView::Helpers::FormBuilder
  TYPE_TO_FIELD = {
    string: :text_field, text: :text_area, integer: :number_field,
    float: :number_field, decimal: :number_field, boolean: :check_box,
    datetime: :datetime_select, date: :date_select, email: :email_field, file: :file_field,
    password: :password_field
  }.freeze

  def input(attribute, options = {})
    as = options.delete(:as)
    collection = options.delete(:collection)
    field_type = as || (collection ? :select : column_type(attribute))
    required = required_attribute?(attribute)
    wrapper_html = options.delete(:wrapper_html) || {}
    label_supplied = options.key?(:label)
    label_text = options.delete(:label) if label_supplied
    hint_text = options.delete(:hint)
    input_html_opts = options.delete(:input_html) || {}

    return hidden_field(attribute, options.merge(input_html_opts)) if field_type == :hidden

    field_html =
      case field_type
      when :select, :grouped_select
        build_select(attribute, collection, options.merge(input_html_opts), field_type == :grouped_select)
      when :check_boxes
        build_check_boxes(attribute, collection, options, input_html_opts)
      else
        send(TYPE_TO_FIELD.fetch(field_type, :text_field), attribute, options.merge(input_html_opts))
      end

    wrap(attribute, field_type, required, label_supplied, label_text, hint_text, wrapper_html) { field_html }
  end

  def input_field(attribute, options = {})
    as = options.delete(:as)
    collection = options.delete(:collection)
    field_type = as || (collection ? :select : column_type(attribute))

    if field_type == :select
      build_select(attribute, collection, options, false)
    else
      send(TYPE_TO_FIELD.fetch(field_type, :text_field), attribute, options)
    end
  end

  def button(type, value = nil, options = {})
    options[:class] = [ "button", options[:class] ].compact.join(" ")

    return submit(value, options) if type == :submit

    super
  end

  def association(attribute, options = {})
    collection    = options.delete(:collection)
    label_method  = options.delete(:label_method) || :to_s
    value_method  = options.delete(:value_method) || :id
    prompt        = options.delete(:prompt)
    include_blank = options.delete(:include_blank)
    label_supplied = options.key?(:label)
    label_text    = options.delete(:label) if label_supplied
    id_attr       = :"#{attribute}_id"

    select_opts = {}
    select_opts[:include_blank] = include_blank unless include_blank.nil?
    select_opts[:prompt] = prompt if prompt

    field_html = collection_select(id_attr, collection, value_method, label_method, select_opts, options)
    wrap(id_attr, :select, required_attribute?(id_attr), label_supplied, label_text, nil, {}) { field_html }
  end

  private

  def column_type(attribute)
    return :password if attribute.to_s.include?("password")
    return :file if attached_file_attribute?(attribute)

    object.class.respond_to?(:type_for_attribute) &&
      object.class.type_for_attribute(attribute.to_s).type || :string
  end

  def attached_file_attribute?(attribute)
    object.class.respond_to?(:attachment_definitions) &&
      object.class.attachment_definitions.key?(attribute.to_sym)
  end

  def required_attribute?(attribute)
    object.class.respond_to?(:validators_on) &&
      object.class.validators_on(attribute).any? { |v| v.is_a?(ActiveModel::Validations::PresenceValidator) }
  end

  def wrap(attribute, type, required, label_supplied, label_text, hint_text, wrapper_html)
    state = required ? "required" : "optional"
    error = object.errors[attribute].any?
    css = [ "input", type, state, ("field_with_errors" if error) ].compact.join(" ")
    label_html = label_text == false ? nil : build_label(attribute, type, state, required, label_supplied, label_text)
    hint_html = hint_text ? @template.content_tag(:span, hint_text, class: "hint") : nil
    error_html = error ? @template.content_tag(:small, object.errors[attribute].first, class: "error") : nil
    @template.content_tag(:div, class: [ css, wrapper_html[:class] ].compact.join(" ")) do
      @template.safe_join([ label_html, yield, hint_html, error_html ].compact)
    end
  end

  def build_label(attribute, type, state, required, label_supplied, label_text)
    label(attribute, class: "#{type} #{state} control-label") do
      text = label_supplied ? label_text : attribute.to_s.humanize
      if required
        abbr = @template.content_tag(:abbr, "*", title: "required")
        @template.safe_join([ text, abbr ])
      else
        text
      end
    end
  end

  def build_select(attribute, collection, options, grouped)
    prompt = options.delete(:prompt)
    include_blank = options.delete(:include_blank)
    default = options.delete(:default)
    label_method = options.delete(:label_method) || :to_s
    value_method = options.delete(:value_method) || (grouped ? :to_s : :id)
    select_options = { prompt: prompt, include_blank: include_blank }.compact
    select_options[:selected] = default if default.present? && object_value(attribute).blank?
    if grouped
      grouped_collection_select(attribute, collection,
                                options.delete(:group_method) || :last,
                                options.delete(:group_label_method) || :first,
                                value_method,
                                label_method,
                                select_options, options)
    else
      select(attribute, option_values(collection, label_method, value_method), select_options, options)
    end
  end

  def build_check_boxes(attribute, collection, options, input_html_opts)
    label_method = options.delete(:label_method) || :last
    value_method = options.delete(:value_method) || :first
    collection_check_boxes(attribute, collection, value_method, label_method, {}, input_html_opts)
  end

  def option_values(collection, label_method, value_method)
    return collection if collection.blank? || collection.first.is_a?(Array)

    collection.map do |item|
      [ value_for(item, label_method), value_for(item, value_method) ]
    end
  end

  def value_for(item, method)
    return method.call(item) if method.respond_to?(:call)
    return item.public_send(method) if item.respond_to?(method)

    item
  end

  def object_value(attribute)
    object.public_send(attribute) if object.respond_to?(attribute)
  end
end
