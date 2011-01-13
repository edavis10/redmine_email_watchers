require File.dirname(__FILE__) + '/../../../test_helper'

class RedmineEmailWatchers::Hooks::ViewLayoutsBaseSidebarTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  context "#view_layouts_base_sidebar" do
    setup do
    end

    should "be tested"
  end
end
