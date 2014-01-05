module ProjectsHelper
  def grouped_bid_category_options(project)
    return [] unless project
    result = []
    original_categories = project.estimates.any? ? project.estimates.first.template.categories_templates.sort_by { |c| c.category.name }.map { |c| c.category } : Array.new
    co_categories = project.estimates.any? && project.cos_categories.any? ? project.cos_categories.sort_by { |c| c.name } : Array.new
    result << ['From estimate', original_categories.map { |c| [c.name, c.id] }] if original_categories.any?
    result << ['From change orders', co_categories.map { |c| [c.name, c.id] }] if co_categories.any?
    result
  end
end
