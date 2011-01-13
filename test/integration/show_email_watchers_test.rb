require 'test_helper'

class ShowEmailWatchersTest < ActionController::IntegrationTest
  should "show email watchers on the sidebar of an issue" do
    @user = User.generate_with_protected!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    login_as

    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @role = Role.generate!(:permissions => [:view_issues, :edit_issues, :add_issue_watchers])
    User.add_to_project(@user, @project, @role)

    assert_difference('Watcher.count') do
      @issue.watchers << Watcher.new(:user => EmailWatcherUser.default, :email_watchers => ['email-only@example.com'])
    end
    
    visit_issue_page(@issue)
    assert_response :success
    
    assert find(:css, 'div#email_watchers')
    assert find(:css, 'div#email_watchers ul li')
    # Can't check the actual email addresses because they are JS encoded (spam)
    assert has_content?('Email Watchers (1)')
  end
end

