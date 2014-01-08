module ProjectsHelper
  def grouped_bid_category_options(project)
    return [] unless project
    result = []
    original_categories = []
    if project.estimates.any?
      project.estimates.each do |e|
        original_categories+= e.template.categories_templates.sort_by { |c| c.category.name }.map { |c| c.category }
      end
    end
    co_categories = project.estimates.any? && project.cos_categories.any? ? project.cos_categories.sort_by { |c| c.name } : Array.new
    result << ['From estimate', original_categories.map { |c| [c.name, c.id] }] if original_categories.any?
    result << ['From change orders', co_categories.map { |c| [c.name, c.id] }] if co_categories.any?
    result
  end
end
