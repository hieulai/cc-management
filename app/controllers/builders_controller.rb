class BuildersController < ApplicationController
  before_filter :authenticate_user!
  
  #Admin actions
  def list
    
  end
  
  #User actions
  def show
  end
  
  #Creation of a builder happens in User->Registration
  
  def edit
    @builder.build_image unless @builder.image.present?
  end
  
  def update
    if @builder.update_attributes(params[:base_builder])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'show')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end
  
  def delete
  end

  def destroy
    @builder.destroy
    redirect_to(:action => 'list')
  end
  

end
