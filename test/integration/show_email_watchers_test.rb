require 'test_helper'

class ShowEmailWatchersTest < ActionController::IntegrationTest
  should "show email watchers on the sidebar of an issue" do
    generate_user_as_project_manager
    
    assert_difference('Watcher.count') do
      @issue.watchers << Watcher.new(:user => EmailWatcherUser.default, :email_watchers => ['email-only@example.com'])
    end
    
    login_as
    visit_issue_page(@issue)
    
    assert find(:css, 'div#email_watchers')
    assert find(:css, 'div#email_watchers ul li')
    # Can't check the actual email addresses because they are JS encoded (spam)
    assert has_content?('Email Watchers (1)')
  end
end

