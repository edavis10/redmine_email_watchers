require 'test_helper'

class EditEmailWatchersTest < ActionController::IntegrationTest
  should "show allow adding email watchers to an issue" do
    generate_user_as_project_manager

    login_as
    visit_issue_page(@issue)
    
    assert find(:css, 'div#email_watchers')
    assert has_content?('Email Watchers (0)')

    add_email_watcher_through_form 'add-new@example.com'

    assert has_content?('Email Watchers (1)')
    assert_issue_is_watched_by_email_watchers(@issue, ['add-new@example.com'])
    
  end

  should "show allow adding additional email watchers to an issue" do
    generate_user_as_project_manager
    login_as
    visit_issue_page(@issue)
    
    assert find(:css, 'div#email_watchers')
    assert has_content?('Email Watchers (0)')
    
    add_email_watcher_through_form 'add-new@example.com'

    assert has_content?('Email Watchers (1)')
    assert_issue_is_watched_by_email_watchers(@issue, ['add-new@example.com'])

    fill_in('Add email watcher', :with => 'second@example.com')
    click_button('Add')
    
    assert_issue_is_watched_by_email_watchers(@issue, ['add-new@example.com', 'second@example.com'])
    
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

