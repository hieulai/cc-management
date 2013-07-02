class ClientsController < ApplicationController

  before_filter :confirm_logged_in

  def list
    @clients = Client.all
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client =  Client.new
  end

  def create
    #Instantiate a new object using form parameters
    @client = Client.new(params[:client])
    #save subject
    if @client.save
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('new')
    end
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    #Find object using form parameters
    @client = Client.find(params[:id])
    #Update subject
    if @client.update_attributes(params[:client])
      #if save succeeds, redirect to list action
      redirect_to(:action => 'list')
    else
      #if save fails, redisplay form to user can fix problems
      render('edit')
    end
  end

  def delete
    @client= Client.find(params[:id])
  end

  def destroy
    Client.find(params[:id]).destroy
    redirect_to(:action => 'list')
  end

end