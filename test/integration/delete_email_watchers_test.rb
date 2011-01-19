require 'test_helper'

class DeleteEmailWatchersTest < ActionController::IntegrationTest
  should "allow deleting email watchers from an issue" do
    generate_user_as_project_manager
    
    assert_difference('Watcher.count') do
      @issue.watchers << Watcher.new(:user => EmailWatcherUser.default, :email_watchers => ['email-only@example.com'])
    end
    
    login_as
    visit_issue_page(@issue)

    assert find(:css, 'div#email_watchers li a.delete')
    within("div#email_watchers") do
      click_link "Delete"
    end
    assert_response :success
    assert has_content?('Email Watchers (0)')

    assert_issue_is_watched_by_email_watchers(@issue, [])
  end
end

