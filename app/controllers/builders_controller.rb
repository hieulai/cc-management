class BuildersController < ApplicationController
  before_filter :authenticate_user!
  
  #Admin actions
  def list
    
  end
  
  #User actions
  def show
    @builder = Base::Builder.find(session[:builder_id])
  end
  
  #Creation of a builder happens in User->Registration
  
  def edit
    @builder = Base::Builder.find(session[:builder_id])
    @builder.build_image unless @builder.image.present?
  end
  
  def update
    #Find object using form parameters
    @builder = Base::Builder.find(session[:builder_id])
    #Update subject
    if @builder.update_attributes(params[:base_builder])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'show')
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
