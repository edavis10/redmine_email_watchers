class EmailWatcherUser < User
  unloadable

  def self.default
    @user = EmailWatcherUser.find_by_login(default_attributes[:login])
    if @user.nil?
      @user = EmailWatcherUser.new(default_attributes)
      @user.login = default_attributes[:login] # Protected
      @user.save
    end
    @user
  end

  def self.default_attributes
    {
      :login => 'email_watcher_user',
      :firstname => 'Email Watcher',
      :lastname => 'Fake Account',
      :mail => 'noreply@example.com'
    }
  end
  
end
