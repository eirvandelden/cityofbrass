class DropTermsOfServices < ActiveRecord::Migration[4.2]
  def change
    drop_table :terms_of_services, if_exists: true
  end
end
