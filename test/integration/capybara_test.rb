require 'test_helper'

class CapybaraTest < ActionController::IntegrationTest
  should "work" do
    @user = User.generate_with_protected!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    login_as

    @project = Project.generate!(:is_public => true)
    visit_project(@project)
    assert find(:css, 'body')
  end
end

