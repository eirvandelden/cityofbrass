require_relative "../test_helper"

class ImporterPreviewUploadTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "resident upload creates preview files with detected kinds and counts" do
    sign_in users(:dan)

    assert_difference("Importer::Preview.count", 1) do
      assert_difference("Importer::PreviewFile.count", 2) do
        post "/imports/previews", params: { files: [ uploaded_file("sample_compendium.xml"), uploaded_file("sample_campaign.xml") ] }
      end
    end

    preview = Importer::Preview.order(:created_at).last
    assert_redirected_to "/imports/previews/#{preview.id}"
    assert_equal "resident_content", preview.mode
    assert_equal residents(:razune), preview.resident

    compendium = preview.preview_files.find_by(detected_kind: "compendium")
    campaign = preview.preview_files.find_by(detected_kind: "campaign")

    assert_equal 2, compendium.entity_counts["monsters"]
    assert_equal 1, compendium.entity_counts["items"]
    assert_equal 1, compendium.entity_counts["spells"]
    assert_equal 1, compendium.entity_counts["races"]
    assert_equal 1, campaign.entity_counts["adventures"]
    assert_equal 1, campaign.entity_counts["encounters"]
    assert_equal 1, campaign.entity_counts["notes"]
    assert_equal 1, campaign.entity_counts["pcs"]
    assert_equal 1, campaign.entity_counts["npcs"]
  end

  test "resident preview form renders a file input" do
    sign_in users(:dan)

    get "/imports/previews/new"

    assert_response :success
    assert_select "input[type=file][name='files[]'][multiple]"
  end

  test "admin upload creates an admin stock preview without a resident" do
    sign_in admins(:dan)

    post "/admin/imports/previews", params: { files: [ uploaded_file("sample_compendium.xml") ] }

    preview = Importer::Preview.order(:created_at).last
    assert_redirected_to "/admin/imports/previews/#{preview.id}"
    assert_equal "admin_stock", preview.mode
    assert_nil preview.resident
    assert_equal "compendium", preview.preview_files.first.detected_kind
  end

  test "admin preview form renders a file input" do
    sign_in admins(:dan)

    get "/admin/imports/previews/new"

    assert_response :success
    assert_select "input[type=file][name='files[]'][multiple]"
  end

  private

  def uploaded_file(name)
    fixture_file_upload(importer_fixture_file(name), "text/xml")
  end
end
