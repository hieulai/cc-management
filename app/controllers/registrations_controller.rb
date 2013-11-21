class RegistrationsController < Devise::RegistrationsController
  layout 'public'

  def create
    #Instantiate a new object using form parameters
    @builder = Base::Builder.new(params[:builder])
    @user = User.new(params[:user])
    @builder.save
    @user.authority = "Owner"
    @user.save

    #save subject
    if @builder.users << @user
      #if save succeeds, redirect to list action
      sign_up(resource_name, resource)
      respond_with resource, :location => after_sign_up_path_for(resource)
    else
      #if save fails, redisplay form to user can fix problems
      render :new
    end
  end
end