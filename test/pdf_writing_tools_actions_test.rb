require 'test_helper'
require 'pdf_writing_tools_actions'

class PdfWritingToolsActionsTest < ActiveSupport::TestCase
  test "test new line action" do
    expected = [{ action_name: :draw_formatted_text, data: [{ text: "\n" }] }]
    p "Test PdfWritingToolsActions::new_line_action"
    assert_equal(expected, PdfWritingToolsActions.new_line_action, "Nope!")
    p "Ok"
  end
end
