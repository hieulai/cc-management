class ApplicationController < ActionController::Base
  before_filter :find_builder

  protect_from_forgery

  protected

  def confirm_logged_in
    unless session[:user_id]
      redirect_to(:controller => 'users', :action => 'login')
      return false
    else
      return true
    end
  end

  def find_builder
    @builder = Builder.find(session[:builder_id]) if session[:builder_id]
  end

end