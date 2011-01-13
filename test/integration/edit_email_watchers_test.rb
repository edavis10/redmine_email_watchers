require 'test_helper'

class EditEmailWatchersTest < ActionController::IntegrationTest
  should "show allow adding email watchers to an issue" do
    generate_user_as_project_manager

    login_as
    visit_issue_page(@issue)
    
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
    generate_user_as_project_manager
    login_as
    visit_issue_page(@issue)
    
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

  should "show validate email watchers before adding" do
    generate_user_as_project_manager
    login_as

    assert_no_difference('Watcher.count') do
      ['', 'just text', 'missing-domain-tld@example'].each do |mail|
        visit_issue_page(@issue)
        fill_in('Add email watcher', :with => mail)
        click_button('Add')

        assert_response :missing
      end
    end
  end
end

