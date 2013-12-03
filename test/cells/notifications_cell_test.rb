require 'test_helper'

class NotificationsCellTest < Cell::TestCase
  test "index" do
    invoke :index
    assert_select "p"
  end
  

end
