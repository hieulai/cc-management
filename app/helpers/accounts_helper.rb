module AccountsHelper

  def select2_account_json
    json = []
    Account.raw(session[:builder_id]).top.each do |a|
      json << a.as_select2_json
    end
    json.to_json
  end
end
