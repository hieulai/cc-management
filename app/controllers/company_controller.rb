class CompanyController < ApplicationController
  before_filter :authenticate_user!
end
