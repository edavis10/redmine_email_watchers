class EmailWatchersController < ApplicationController
  unloadable
  before_filter :find_project
  before_filter :authorize
  before_filter :validate_mail_format, :only => [:create]
  
  def create
    @watcher = Watcher.first(:conditions => {
                               :user_id => EmailWatcherUser.default.id,
                               :watchable_type => params[:object_type].camelcase,
                               :watchable_id => params[:object_id]
                             })
    @watcher ||= Watcher.new(params[:watcher])
    @watcher.email_watchers ||= []
    @watcher.email_watchers << params[:add_email_watcher]
    @watcher.watchable = @watched
    @watcher.user = EmailWatcherUser.default
    @watcher.save if request.post?
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'email_watchers', :partial => 'email_watchers/list', :locals => {:watched => @watched}
        end
      end
    end
  rescue ::ActionController::RedirectBackError
    render :text => 'Watcher added.', :layout => true
  end

  def destroy
    # TODO: needs to check for HTTP POST but also allow normal links
    if params[:delete_email_watcher].present?
      @watcher = Watcher.first(:conditions => {
                                 :user_id => EmailWatcherUser.default.id,
                                 :watchable_type => params[:object_type].camelcase,
                                 :watchable_id => params[:object_id]
                               })
      @watcher.email_watchers.delete(params[:delete_email_watcher])
      @watcher.save
    end
    
    respond_to do |format|
      format.html { redirect_to :back }
      format.js do
        render :update do |page|
          page.replace_html 'email_watchers', :partial => 'email_watchers/list', :locals => {:watched => @watched}
          page << 'Element.hide("new-email-watcher-form");'
        end
      end
    end
  end

  private
  
  def find_project
    klass = Object.const_get(params[:object_type].camelcase)
    return false unless klass.respond_to?('watched_by')
    @watched = klass.find(params[:object_id])
    @project = @watched.project
  rescue
    render_404
  end

  # Taken from User.rb
  MAIL_REGEX = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i

  # TODO: move to a model, but which one?
  def validate_mail_format
    if params[:add_email_watcher] && params[:add_email_watcher].match(MAIL_REGEX)
      true
    else
      render_404
    end
  end
end
