require 'test_helper'

class AffiliationsControllerTest < ActionController::TestCase

  setup do
    @dan = users(:dan)
    @razune = residents(:razune)
    @eleanor = residents(:eleanor)
    @affiliation = affiliations(:affiliation1)
  end

end
