module BidsHelper
  def grouped_bid_category_options(estimate)
    return [] unless estimate
    result = []
    original_categories = []
    original_categories+= estimate.template.categories_templates.sort_by { |c| c.category.name }.map { |c| c.category }
    co_categories = estimate.project.cos_categories.any? ? estimate.project.cos_categories.sort_by { |c| c.name } : Array.new
    result << ['From estimate', original_categories.map { |c| [c.name, c.id] }] if original_categories.any?
    result << ['From change orders', co_categories.map { |c| [c.name, c.id] }] if co_categories.any?
    result
  end
end
