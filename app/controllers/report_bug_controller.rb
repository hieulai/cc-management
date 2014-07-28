class ReportBugController < ApplicationController
  before_filter :authenticate_user!

  def report
    @bug = Bug.new(params[:bug])
    if @bug.valid?
      BitBucket.new.issues.create BitBucket.user, BitBucket.repo, {:title => @bug.title, :content => @bug.description, :kind => "bug", :priority => "major"}
    end
    respond_to do |format|
      format.js {}
    end
  end
end
