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

    post "/admin/imports", params: { preview_id: preview.id }

    assert_response :forbidden
    assert_equal 0, Importer::Import.admin_stock.count
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
