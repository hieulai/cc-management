class ProspectingController < ApplicationController
  def list
    @query = params[:query]
    @prospects = Prospect.where("builder_id = ?", session[:builder_id]).search(@query)
  end

  def show
    @prospect = Prospect.find(params[:id])
  end

  def new
    @prospect =  Prospect.new
  end

  def create
    #Instantiate a new object using form parameters
    @builder = Builder.find(session[:builder_id])
    @prospect = Prospect.new(params[:prospect])
    #save subject
    if @prospect.save
      @builder.prospects << @prospect
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end

  def edit
    @prospect = Prospect.find(params[:id])
  end

  def update
    #Find object using form parameters
    @prospect = Prospect.find(params[:id])
    #Update subject
    if @prospect.update_attributes(params[:prospect])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    @prospect= Prospect.find(params[:id])
  end

  def destroy
    Prospect.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end
end
