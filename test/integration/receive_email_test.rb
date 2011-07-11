require 'test_helper'

class ReceiveEmailTest < ActionController::IntegrationTest
  def self.should_allow_email_watchers_to_reply(options={})
    email_fixture = options[:fixture]
    
    should "allow receiving email from email watchers to edit an issue" do
      generate_user_as_project_manager
      @issue.init_journal(@user, 'A journal note')
      assert @issue.save
      @journal = @issue.journals.last
      
      login_as
      visit_issue_page(@issue)

      add_email_watcher_through_form 'jsmith@somenet.foo'

      mail = IO.read(email_fixture)
      mail.gsub!('{{issue-id}}', @issue.id.to_s)
      mail.gsub!('{{journal-id}}', @journal.id.to_s)

      assert_difference('Journal.count') do
        MailHandler.receive(mail)
      end

    end

    should "allow receiving email from email watchers to edit an issue on private projects" do
      generate_user_as_project_manager
      @issue.init_journal(@issue.author,'A journal note')
      assert @issue.save
      @journal = @issue.journals.last      
      @project.update_attribute(:is_public, false)
      @project.reload

      login_as
      visit_issue_page(@issue)

      add_email_watcher_through_form 'jsmith@somenet.foo'

      mail = IO.read(email_fixture)
      mail.gsub!('{{issue-id}}', @issue.id.to_s)
      mail.gsub!('{{journal-id}}', @journal.id.to_s)
      
      assert_difference('Journal.count') do
        MailHandler.receive(mail)
      end

    end

    should "allow not all receiving email from email watchers to a different issue" do
      generate_user_as_project_manager
      @issue.init_journal('A journal note')
      assert @issue.save
      @journal = @issue.journals.last
      
      login_as
      visit_issue_page(@issue)

      add_email_watcher_through_form 'jsmith@somenet.foo'

      # Second issue they aren't watching
      @issue2 = Issue.generate_for_project!(@project)
      @journal2 = @issue2.init_journal(@issue2.author, 'A journal note')
      assert @issue2.save
      
      mail = IO.read(email_fixture)
      mail.gsub!('{{issue-id}}', @issue2.id.to_s)
      mail.gsub!('{{journal-id}}', @journal2.id.to_s)
      
      assert_difference('Journal.count', 0) do
        MailHandler.receive(mail)
      end

    end

  end
  
  context "from an issue email" do
    should_allow_email_watchers_to_reply(:fixture => File.dirname(__FILE__) + '/../fixtures/incoming_mail/reply.eml')
  end

  context "from a journal email" do
    should_allow_email_watchers_to_reply(:fixture => File.dirname(__FILE__) + '/../fixtures/incoming_mail/reply_to_journal.eml')
  end
end
