class ApplicationController < ActionController::Base
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

end