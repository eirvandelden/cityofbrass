class GroupedCollectionSelectInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  def input_html_classes
    super.push('select2-basic')
  end
end
