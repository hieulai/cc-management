module ItemsHelper
  def count_price(item)
    if item.cost && item.margin
      item.cost + item.margin
    elsif item.cost && item.margin.nil?
      item.cost
    elsif item.cost.nil? && item.margin
      item.margin
    elsif item.cost.nil? && item.margin.nil?
      0
    end
  end
end