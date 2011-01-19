require File.dirname(__FILE__) + '/../../../test_helper'

class RedmineEmailWatchers::Hooks::ModelMailHandlerFindUserTest < ActionController::IntegrationTest
  include Redmine::Hook::Helper

  context "#model_mail_handler_find_user" do
    setup do
    end

    should "be tested"
  end
end
