require "test_helper"

class PaperclipStorageTest < ActiveSupport::TestCase
  ATTACHMENT_MODELS = [
    Gallery::FaqImage,
    Gallery::MapImage,
    Gallery::ResidentImage,
    Gallery::StockImage,
    Importer::ImportFile,
    Importer::PreviewFile
  ].freeze

  test "paperclip attachments store files under storage" do
    ATTACHMENT_MODELS.each do |model|
      path = model.new.file.options[:path]

      assert_match %r{\A:rails_root/storage/paperclip/}, path, "#{model.name} stores outside storage"
    end
  end

  test "paperclip attachments use server URLs" do
    ATTACHMENT_MODELS.each do |model|
      url = model.new.file.options[:url]

      assert_match %r{\A/paperclip/}, url, "#{model.name} does not use server URLs"
    end
  end

  test "paperclip uses filesystem storage" do
    assert_equal :filesystem, Paperclip::Attachment.default_options[:storage]
  end

  test "production paperclip defaults keep legacy attachment folder" do
    production_config = Rails.root.join("config/environments/production.rb").read

    assert_includes production_config, 'path: ":rails_root/storage/attachments/:class/:attachment/:id_partition/:style/:filename"'
    assert_includes production_config, 'url: "/attachments/:class/:attachment/:id_partition/:style/:filename"'
  end
end
