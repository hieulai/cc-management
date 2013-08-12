class RegistrationsController < Devise::RegistrationsController
  layout 'public'

  def create
    #Instantiate a new object using form parameters
    @builder = Builder.new(params[:builder])
    @user = User.new(params[:user])
    @builder.save
    @user.authority = "Owner"
    @user.save

    #save subject
    if @builder.users << @user
      #if save succeeds, redirect to list action
      redirect_to new_user_session_path
    else
      #if save fails, redisplay form to user can fix problems
      render :create
    end
  end
end