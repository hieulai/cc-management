class BuildersController < ApplicationController
  
  #Filters
  before_filter :confirm_logged_in
  
  #Admin actions
  def list_users
    @builder = Builder.find(session[:builder_id])
  end
  
  #User actions
  def show
    @builder = Builder.find(session[:builder_id])
  end
  
  #Creation of a builder happens in User->Registration
  
  def edit
    @builder = Builder.find(session[:builder_id])
  end
  
  def update
    #Find object using form parameters
    @account = Account.find(params[:id])
    #Update subject
    if @account.update_attributes(params[:account])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
    @account = Account.find(params[:id])
  end

  def destroy
    Account.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
  

end
