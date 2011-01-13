require 'test_helper'

class EditEmailWatchersTest < ActionController::IntegrationTest
  should "show allow adding email watchers to an issue" do
    @user = User.generate_with_protected!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    login_as

    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @role = Role.generate!(:permissions => [:view_issues, :edit_issues, :view_issue_email_watchers, :add_issue_email_watchers])
    User.add_to_project(@user, @project, @role)

    visit_issue_page(@issue)
    assert_response :success
    
    assert find(:css, 'div#email_watchers')
    assert has_content?('Email Watchers (0)')
    
    fill_in('Add email watcher', :with => 'add-new@example.com')
    click_button('Add')

    assert_response :success
    assert has_content?('Email Watchers (1)')
    watchers = Watcher.all(:conditions => {
                             :watchable_id => @issue.id,
                             :watchable_type => 'Issue',
                             :user_id => EmailWatcherUser.default.id
                           })
    assert_equal 1, watchers.length
    assert_equal ['add-new@example.com'], watchers.first.email_watchers
    
  end

  should "show allow adding additional email watchers to an issue" do
    @user = User.generate_with_protected!(:login => 'existing', :password => 'existing', :password_confirmation => 'existing')
    login_as

    @project = Project.generate!(:is_public => true)
    @issue = Issue.generate_for_project!(@project)
    @role = Role.generate!(:permissions => [:view_issues, :edit_issues, :view_issue_email_watchers, :add_issue_email_watchers])
    User.add_to_project(@user, @project, @role)

    visit_issue_page(@issue)
    assert_response :success
    
    assert find(:css, 'div#email_watchers')
    assert has_content?('Email Watchers (0)')
    
    fill_in('Add email watcher', :with => 'add-new@example.com')
    click_button('Add')

    assert_response :success
    assert has_content?('Email Watchers (1)')

    fill_in('Add email watcher', :with => 'second@example.com')
    click_button('Add')
    
    watchers = Watcher.all(:conditions => {
                             :watchable_id => @issue.id,
                             :watchable_type => 'Issue',
                             :user_id => EmailWatcherUser.default.id
                           })
    assert_equal 1, watchers.length
    assert_equal ['add-new@example.com', 'second@example.com'], watchers.first.email_watchers.sort
    
  end
end

