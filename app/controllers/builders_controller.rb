class BuildersController < ApplicationController
  
  before_filter :confirm_logged_in
  
  def index
    #verfiy syntax 
    render(projects/index)
  end

end
