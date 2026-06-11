require_relative "../test_helper"

class ImporterImportFlowTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
  include Devise::Test::IntegrationHelpers

  test "resident confirms a preview and imports content" do
    sign_in users(:dan)
    post "/imports/previews", params: { files: [ uploaded_file("sample_compendium.xml") ] }
    preview = Importer::Preview.order(:created_at).last

    perform_enqueued_jobs do
      post "/imports", params: { preview_id: preview.id }
    end

    import = Importer::Import.order(:created_at).last
    assert_redirected_to "/imports/#{import.id}"
    assert_equal "succeeded", import.status
    assert_equal residents(:razune), Entitybuilder::ResidentCreature.find_by!(name: "Goblin").resident
  end

  test "queued resident import shows the files waiting to process" do
    sign_in users(:dan)
    post "/imports/previews", params: { files: [ uploaded_file("sample_compendium.xml") ] }
    preview = Importer::Preview.order(:created_at).last

    post "/imports", params: { preview_id: preview.id }
    import = Importer::Import.order(:created_at).last
    get "/imports/#{import.id}"

    assert_response :success
    assert_select "h2", text: I18n.t("importer.imports.show.files")
    assert_select "td", text: "sample_compendium.xml"
    assert_select "td", text: "compendium"
    assert_select "td", text: "queued"
  end

  test "admin confirms a stock preview and imports shared content" do
    sign_in admins(:dan)
    post "/admin/imports/previews", params: { files: [ uploaded_file("sample_compendium.xml") ] }
    preview = Importer::Preview.order(:created_at).last

    perform_enqueued_jobs do
      post "/admin/imports", params: { preview_id: preview.id }
    end

    import = Importer::Import.order(:created_at).last
    assert_redirected_to "/admin/imports/#{import.id}"
    assert_equal "succeeded", import.status
    assert_equal "Residents", Entitybuilder::StockCreature.find_by!(name: "Goblin").privacy
  end

  test "normal user cannot confirm an admin stock preview" do
    preview = admin_preview
    sign_in users(:dan)

    assert_no_difference("Importer::Import.admin_stock.count") do
      post "/admin/imports", params: { preview_id: preview.id }
    end

    assert_response :forbidden
  end

  private

  def admin_preview
    Importer::Preview.create!(mode: Importer::Preview::ADMIN_STOCK, source: Importer::Preview::GAME_MASTER_5_XML,
                              status: "ready")
  end

  def uploaded_file(name)
    fixture_file_upload(importer_fixture_file(name), "text/xml")
  end
end
