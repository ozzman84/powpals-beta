# frozen_string_literal: true

module ApplicationHelper
  def navigation_items
    [
      { body: 'Dashboard', href: '#' },
      { body: 'Lodgings', href: users_lodgings_path },
      { body: 'PowPals', href: '#' },
      { body: 'Calendar', href: '#' },
      { body: 'Expenses', href: '#' }
    ]
  end

  def navigation_class(path)
    if current_page?(path)
      'bg-gray-900 text-white rounded-md px-3 py-2 text-sm font-medium'
    else
      'text-gray-300 hover:bg-gray-700 hover:text-white rounded-md px-3 py-2 text-sm font-medium'
    end
  end

  def navigation_aria(path)
    if current_page?(path)
      'page'
    else
      'false'
    end
  end
end
