# frozen_string_literal: false

class DropTermsOfServices < ActiveRecord::Migration
  def change
    drop_table :terms_of_services
  end
end
