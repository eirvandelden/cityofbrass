class DropTermsOfServices < ActiveRecord::Migration[4.2]
  def change
    drop_table :terms_of_services
  end
end
